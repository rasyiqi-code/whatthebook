create table public.users (
  id uuid not null default auth.uid (),
  email text not null,
  full_name text null,
  username text null,
  bio text null,
  avatar_url text null,
  followers_count integer null default 0,
  following_count integer null default 0,
  books_count integer null default 0,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  role text not null default 'reader'::text,
  contact text null,
  constraint users_pkey primary key (id),
  constraint users_email_key unique (email),
  constraint users_username_key unique (username),
  constraint users_id_fkey foreign KEY (id) references auth.users (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_users_email on public.users using btree (email) TABLESPACE pg_default;

create index IF not exists idx_users_username on public.users using btree (username) TABLESPACE pg_default;

create index IF not exists idx_users_created_at on public.users using btree (created_at) TABLESPACE pg_default;

create index IF not exists idx_users_role on public.users using btree (role) TABLESPACE pg_default;

create trigger update_users_updated_at BEFORE
update on users for EACH row
execute FUNCTION update_updated_at_column ();

______

create view public.user_stats as
select
  u.id as user_id,
  COALESCE(sum(length(c.content)), 0::bigint) as total_words,
  count(distinct b.id) filter (
    where
      b.status = 'published'::text
  ) as books_published,
  count(distinct c.id) filter (
    where
      c.status = 'published'::text
  ) as chapters_published,
  0 as writing_streak,
  (
    select
      count(distinct rp.book_id) as count
    from
      reading_progress rp
    where
      rp.user_id = u.id
      and rp.book_id is not null
  ) as books_read,
  (
    select
      count(*) as count
    from
      reviews r
    where
      r.user_id = u.id
  ) as reviews_written,
  (
    select
      count(*) as count
    from
      book_likes bl
      join books b2 on bl.book_id = b2.id
    where
      b2.author_id = u.id
  ) as likes_received,
  0 as reading_streak,
  null::text as genre_favorite
from
  users u
  left join books b on b.author_id = u.id
  left join chapters c on c.book_id = b.id
group by
  u.id;

________

create view public.user_productivity_monthly as
select
  u.id as user_id,
  to_char(months.month, 'YYYY-MM'::text) as year_month,
  COALESCE(
    sum(
      case
        when c.status = 'published'::text
        and to_char(c.created_at, 'YYYY-MM'::text) = to_char(months.month, 'YYYY-MM'::text) then length(c.content)
        else 0
      end
    ),
    0::bigint
  ) as total_words,
  count(distinct b.id) filter (
    where
      b.status = 'published'::text
      and to_char(b.created_at, 'YYYY-MM'::text) = to_char(months.month, 'YYYY-MM'::text)
  ) as books_published,
  count(distinct c.id) filter (
    where
      c.status = 'published'::text
      and to_char(c.created_at, 'YYYY-MM'::text) = to_char(months.month, 'YYYY-MM'::text)
  ) as chapters_published,
  (
    select
      count(*) as count
    from
      reviews r
    where
      r.user_id = u.id
      and to_char(r.created_at, 'YYYY-MM'::text) = to_char(months.month, 'YYYY-MM'::text)
  ) as reviews_written,
  (
    select
      count(*) as count
    from
      book_likes bl
      join books b2 on bl.book_id = b2.id
    where
      b2.author_id = u.id
      and to_char(bl.created_at, 'YYYY-MM'::text) = to_char(months.month, 'YYYY-MM'::text)
  ) as likes_received
from
  users u
  cross join (
    select
      generate_series(
        date_trunc(
          'month'::text,
          (
            select
              min(chapters.created_at) as min
            from
              chapters
          )
        ),
        date_trunc('month'::text, now()),
        '1 mon'::interval
      ) as month
  ) months
  left join books b on b.author_id = u.id
  left join chapters c on c.book_id = b.id
group by
  u.id,
  months.month
order by
  u.id,
  (to_char(months.month, 'YYYY-MM'::text));


______

create table public.reviews (
  id uuid not null default extensions.uuid_generate_v4 (),
  user_id uuid null,
  book_id uuid null,
  rating integer null,
  review_text text null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint reviews_pkey primary key (id),
  constraint reviews_user_id_book_id_key unique (user_id, book_id),
  constraint reviews_book_id_fkey foreign KEY (book_id) references books (id) on delete CASCADE,
  constraint reviews_rating_check check (
    (
      (rating >= 1)
      and (rating <= 5)
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_reviews_book on public.reviews using btree (book_id) TABLESPACE pg_default;

______

create table public.reading_progress (
  id uuid not null default extensions.uuid_generate_v4 (),
  book_id uuid null,
  chapter_id uuid null,
  progress_percentage numeric null,
  last_read_at timestamp with time zone null default now(),
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  user_id uuid null,
  pdf_book_id uuid null,
  constraint reading_progress_pkey primary key (id),
  constraint reading_progress_user_pdf_book_id_unique unique (user_id, pdf_book_id),
  constraint reading_progress_user_book_id_unique unique (user_id, book_id),
  constraint reading_progress_user_id_fkey foreign KEY (user_id) references auth.users (id) on delete CASCADE,
  constraint reading_progress_book_id_fkey foreign KEY (book_id) references books (id) on delete CASCADE,
  constraint reading_progress_chapter_id_fkey foreign KEY (chapter_id) references chapters (id) on delete CASCADE,
  constraint reading_progress_pdf_book_id_fkey foreign KEY (pdf_book_id) references pdf_books (id) on delete CASCADE,
  constraint reading_progress_progress_percentage_check check (
    (
      (progress_percentage >= (0)::numeric)
      and (progress_percentage <= (100)::numeric)
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_reading_progress_user_id on public.reading_progress using btree (user_id) TABLESPACE pg_default;

create index IF not exists idx_reading_progress_pdf_book_id on public.reading_progress using btree (pdf_book_id) TABLESPACE pg_default;

create index IF not exists idx_reading_progress_book_id on public.reading_progress using btree (book_id) TABLESPACE pg_default;

create index IF not exists idx_reading_progress_chapter_id on public.reading_progress using btree (chapter_id) TABLESPACE pg_default;

______

create table public.reading_lists (
  id uuid not null default gen_random_uuid (),
  user_id uuid not null,
  name text not null,
  description text null,
  is_public boolean not null default true,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint reading_lists_pkey primary key (id),
  constraint reading_lists_user_id_fkey foreign KEY (user_id) references users (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_reading_lists_user_id on public.reading_lists using btree (user_id) TABLESPACE pg_default;

______

create table public.reading_list_books (
  id uuid not null default gen_random_uuid (),
  reading_list_id uuid not null,
  book_id uuid not null,
  added_at timestamp with time zone null default now(),
  constraint reading_list_books_pkey primary key (id),
  constraint reading_list_books_unique unique (reading_list_id, book_id),
  constraint reading_list_books_book_id_fkey foreign KEY (book_id) references books (id) on delete CASCADE,
  constraint reading_list_books_reading_list_id_fkey foreign KEY (reading_list_id) references reading_lists (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_reading_list_books_reading_list_id on public.reading_list_books using btree (reading_list_id) TABLESPACE pg_default;

create index IF not exists idx_reading_list_books_book_id on public.reading_list_books using btree (book_id) TABLESPACE pg_default;

______

create table public.pdf_books (
  id uuid not null default gen_random_uuid (),
  title text not null,
  description text null,
  author_id uuid not null,
  pdf_url text not null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  book_author text null,
  publication_year integer null,
  category text null,
  language text null default 'Indonesian'::text,
  pages integer null,
  isbn text null,
  cover_image_url text null,
  file_size bigint null,
  file_name text null,
  upload_status text null default 'completed'::text,
  constraint pdf_books_pkey primary key (id),
  constraint pdf_books_author_id_fkey foreign KEY (author_id) references auth.users (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_pdf_books_author_id on public.pdf_books using btree (author_id) TABLESPACE pg_default;

create index IF not exists idx_pdf_books_created_at on public.pdf_books using btree (created_at desc) TABLESPACE pg_default;

create index IF not exists idx_pdf_books_category on public.pdf_books using btree (category) TABLESPACE pg_default;

create index IF not exists idx_pdf_books_language on public.pdf_books using btree (language) TABLESPACE pg_default;

create index IF not exists idx_pdf_books_book_author on public.pdf_books using btree (book_author) TABLESPACE pg_default;

create index IF not exists idx_pdf_books_upload_status on public.pdf_books using btree (upload_status) TABLESPACE pg_default;

create index IF not exists idx_pdf_books_file_size on public.pdf_books using btree (file_size) TABLESPACE pg_default;

create trigger update_pdf_books_updated_at BEFORE
update on pdf_books for EACH row
execute FUNCTION update_updated_at_column ();


_____


create table public.pdf_bookmarks (
  id uuid not null default gen_random_uuid (),
  pdf_book_id uuid not null,
  page_index integer not null,
  note text null,
  bookmark_name text null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  user_id uuid not null,
  page integer not null default 0,
  constraint pdf_bookmarks_pkey primary key (id),
  constraint pdf_bookmarks_user_id_pdf_book_id_page_index_key unique (user_id, pdf_book_id, page_index),
  constraint pdf_bookmarks_pdf_book_id_fkey foreign KEY (pdf_book_id) references pdf_books (id) on delete CASCADE,
  constraint pdf_bookmarks_user_id_fkey foreign KEY (user_id) references auth.users (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_pdf_bookmarks_created_at on public.pdf_bookmarks using btree (created_at desc) TABLESPACE pg_default;

create index IF not exists idx_pdf_bookmarks_pdf_book_id on public.pdf_bookmarks using btree (pdf_book_id) TABLESPACE pg_default;

create index IF not exists idx_pdf_bookmarks_user_id on public.pdf_bookmarks using btree (user_id) TABLESPACE pg_default;

______

create table public.follows (
  id uuid not null default extensions.uuid_generate_v4 (),
  follower_id uuid null,
  following_id uuid null,
  created_at timestamp with time zone null default now(),
  constraint follows_pkey primary key (id),
  constraint follows_follower_id_following_id_key unique (follower_id, following_id),
  constraint follows_check check ((follower_id <> following_id))
) TABLESPACE pg_default;

create index IF not exists idx_follows_follower_id on public.follows using btree (follower_id) TABLESPACE pg_default;

create index IF not exists idx_follows_following_id on public.follows using btree (following_id) TABLESPACE pg_default;

create index IF not exists idx_follows_follower on public.follows using btree (follower_id) TABLESPACE pg_default;

create trigger update_followers_count
after INSERT
or DELETE on follows for EACH row
execute FUNCTION update_user_followers_count ();

_____


create view public.community_productivity_monthly as
select
  year_month,
  avg(total_words) as avg_total_words,
  avg(books_published) as avg_books_published,
  avg(chapters_published) as avg_chapters_published,
  avg(reviews_written) as avg_reviews_written,
  avg(likes_received) as avg_likes_received
from
  user_productivity_monthly
group by
  year_month
order by
  year_month;

____

create table public.comments (
  id uuid not null default gen_random_uuid (),
  user_id uuid not null,
  book_id uuid not null,
  chapter_id uuid null,
  content text not null,
  parent_comment_id uuid null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint comments_pkey primary key (id),
  constraint comments_book_id_fkey foreign KEY (book_id) references books (id) on delete CASCADE,
  constraint comments_chapter_id_fkey foreign KEY (chapter_id) references chapters (id) on delete CASCADE,
  constraint comments_parent_comment_id_fkey foreign KEY (parent_comment_id) references comments (id) on delete CASCADE,
  constraint comments_user_id_fkey foreign KEY (user_id) references users (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_comments_user_id on public.comments using btree (user_id) TABLESPACE pg_default;

create index IF not exists idx_comments_book_id on public.comments using btree (book_id) TABLESPACE pg_default;

create index IF not exists idx_comments_chapter_id on public.comments using btree (chapter_id) TABLESPACE pg_default;

create index IF not exists idx_comments_parent_comment_id on public.comments using btree (parent_comment_id) TABLESPACE pg_default;

___________

create table public.chapters (
  id uuid not null default extensions.uuid_generate_v4 (),
  book_id uuid null,
  title text not null,
  content text not null,
  chapter_number integer not null,
  word_count integer null default 0,
  status text not null default 'draft'::text,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint chapters_pkey primary key (id),
  constraint chapters_book_id_fkey foreign KEY (book_id) references books (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_chapters_book on public.chapters using btree (book_id) TABLESPACE pg_default;

create index IF not exists idx_chapters_status on public.chapters using btree (status) TABLESPACE pg_default;

create trigger trg_update_words_achievement
after INSERT on chapters for EACH row
execute FUNCTION update_words_achievement ();

_________

create view public.books_with_metadata as
select
  b.id,
  b.title,
  b.description,
  b.cover_image_url,
  b.author_id,
  b.status,
  b.genre,
  b.tags,
  u.full_name as author_name,
  u.username as author_username,
  u.avatar_url as author_avatar_url,
  u.role as author_role,
  COALESCE(l.likes_count, 0::bigint) as likes_count,
  COALESCE(v.views_count, 0::bigint) as views_count,
  COALESCE(v.recent_views, 0::bigint) as recent_views
from
  books b
  left join users u on b.author_id = u.id
  left join (
    select
      book_likes.book_id,
      count(*) as likes_count
    from
      book_likes
    group by
      book_likes.book_id
  ) l on b.id = l.book_id
  left join (
    select
      book_views.book_id,
      count(*) as views_count,
      count(
        case
          when book_views.viewed_at > (now() - '7 days'::interval) then 1
          else null::integer
        end
      ) as recent_views
    from
      book_views
    group by
      book_views.book_id
  ) v on b.id = v.book_id; 

  __________

  create table public.books (
  id uuid not null default extensions.uuid_generate_v4 (),
  title text not null,
  description text null,
  cover_image_url text null,
  author_id uuid null,
  status text not null default 'draft'::text,
  genre text null,
  tags text[] null,
  total_chapters integer null default 0,
  total_words integer null default 0,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint books_pkey primary key (id),
  constraint books_author_id_fkey foreign KEY (author_id) references users (id) on delete set null
) TABLESPACE pg_default;

create index IF not exists idx_books_author on public.books using btree (author_id) TABLESPACE pg_default;

create index IF not exists idx_books_status on public.books using btree (status) TABLESPACE pg_default;

create trigger trg_update_books_count_after_delete
after DELETE on books for EACH row
execute FUNCTION update_books_count ();

create trigger trg_update_books_count_after_insert
after INSERT on books for EACH row
execute FUNCTION update_books_count ();

create trigger trg_update_books_count_after_update
after
update OF author_id on books for EACH row
execute FUNCTION update_books_count ();

________

create table public.bookmarks (
  id uuid not null default extensions.uuid_generate_v4 (),
  book_id uuid not null,
  created_at timestamp with time zone null default now(),
  user_id uuid not null,
  chapter_id uuid null,
  page_index integer null default 0,
  note text null,
  bookmark_name text null,
  constraint bookmarks_pkey primary key (id),
  constraint bookmarks_book_id_fkey foreign KEY (book_id) references books (id) on delete CASCADE,
  constraint bookmarks_chapter_id_fkey foreign KEY (chapter_id) references chapters (id) on delete CASCADE,
  constraint bookmarks_user_id_fkey foreign KEY (user_id) references auth.users (id) on delete CASCADE,
  constraint bookmarks_page_index_check check ((page_index >= 0)),
  constraint bookmarks_position_check check (
    (
      (chapter_id is not null)
      or (book_id is not null)
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_bookmarks_user_id on public.bookmarks using btree (user_id) TABLESPACE pg_default;

create index IF not exists idx_bookmarks_book_id on public.bookmarks using btree (book_id) TABLESPACE pg_default;

create index IF not exists idx_bookmarks_created_at on public.bookmarks using btree (created_at) TABLESPACE pg_default;

create index IF not exists idx_bookmarks_chapter_id on public.bookmarks using btree (chapter_id) TABLESPACE pg_default;

create index IF not exists idx_bookmarks_page_index on public.bookmarks using btree (page_index) TABLESPACE pg_default;

_________

create table public.book_views (
  id uuid not null default gen_random_uuid (),
  book_id uuid not null,
  user_id uuid null,
  viewed_at timestamp with time zone null default now(),
  constraint book_views_pkey primary key (id),
  constraint book_views_book_id_fkey foreign KEY (book_id) references books (id) on delete CASCADE,
  constraint book_views_user_id_fkey foreign KEY (user_id) references users (id) on delete set null
) TABLESPACE pg_default;

create index IF not exists idx_book_views_book_id on public.book_views using btree (book_id) TABLESPACE pg_default;

create index IF not exists idx_book_views_user_id on public.book_views using btree (user_id) TABLESPACE pg_default;

create index IF not exists idx_book_views_viewed_at on public.book_views using btree (viewed_at) TABLESPACE pg_default;

__________

create table public.book_likes (
  id uuid not null default gen_random_uuid (),
  user_id uuid not null,
  book_id uuid not null,
  created_at timestamp with time zone null default now(),
  constraint book_likes_pkey primary key (id),
  constraint book_likes_unique unique (user_id, book_id),
  constraint book_likes_book_id_fkey foreign KEY (book_id) references books (id) on delete CASCADE,
  constraint book_likes_user_id_fkey foreign KEY (user_id) references users (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_book_likes_user_id on public.book_likes using btree (user_id) TABLESPACE pg_default;

create index IF not exists idx_book_likes_book_id on public.book_likes using btree (book_id) TABLESPACE pg_default;

________

create table public.banners (
  id uuid not null default extensions.uuid_generate_v4 (),
  image_url text not null,
  created_at timestamp with time zone null default timezone ('utc'::text, now()),
  updated_at timestamp with time zone null default timezone ('utc'::text, now()),
  is_active boolean not null default true,
  constraint banners_pkey primary key (id)
) TABLESPACE pg_default;

________

create view public.author_leaderboard_weekly as
select
  u.id as author_id,
  u.full_name,
  u.avatar_url,
  count(distinct b.id) as books_count,
  count(r.id) as reviews_count,
  avg(r.rating) as avg_rating
from
  users u
  join books b on b.author_id = u.id
  join reviews r on r.book_id = b.id
where
  r.created_at >= (now() - '7 days'::interval)
group by
  u.id,
  u.full_name,
  u.avatar_url
having
  count(r.id) > 0
order by
  (avg(r.rating)) desc,
  (count(r.id)) desc
limit
  10;

_______

create view public.author_leaderboard_monthly as
select
  u.id as author_id,
  u.full_name,
  u.avatar_url,
  count(distinct b.id) as books_count,
  count(r.id) as reviews_count,
  avg(r.rating) as avg_rating
from
  users u
  join books b on b.author_id = u.id
  join reviews r on r.book_id = b.id
where
  r.created_at >= (now() - '30 days'::interval)
group by
  u.id,
  u.full_name,
  u.avatar_url
having
  count(r.id) > 0
order by
  (avg(r.rating)) desc,
  (count(r.id)) desc
limit
  10;

________

create view public.author_leaderboard_alltime as
select
  u.id as author_id,
  u.full_name,
  u.avatar_url,
  count(distinct b.id) as books_count,
  count(r.id) as reviews_count,
  avg(r.rating) as avg_rating
from
  users u
  join books b on b.author_id = u.id
  join reviews r on r.book_id = b.id
group by
  u.id,
  u.full_name,
  u.avatar_url
having
  count(r.id) > 0
order by
  (avg(r.rating)) desc,
  (count(r.id)) desc
limit
  10;