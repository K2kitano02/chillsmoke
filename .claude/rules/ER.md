# ER図(dbdiagram)

```
Table users {
  id integer [pk, increment]
  name varchar [not null]
  email varchar [not null, unique]
  encrypted_password varchar [not null]
  reset_password_token varchar [unique]
  reset_password_sent_at timestamp
  remember_created_at timestamp
  created_at timestamp
  updated_at timestamp
}

Table user_settings {
  id integer [pk, increment]
  user_id integer [not null, unique]
  target_daily_cigarette_count integer [not null]
  baseline_daily_cigarette_count integer [not null]
  pack_price integer [not null]
  cigarettes_per_pack integer [not null, default: 20]
  is_oni_mode boolean [not null, default: false]
  created_at timestamp
  updated_at timestamp
}

Table user_smoking_logs {
  id integer [pk, increment]
  user_id integer [not null]
  smoked_on date [not null]
  smoking_count integer [not null, default: 0]
  target_daily_cigarette_count_snapshot integer [not null]
  baseline_daily_cigarette_count_snapshot integer [not null]
  pack_price_snapshot integer [not null]
  cigarettes_per_pack_snapshot integer [not null]
  is_oni_mode_snapshot boolean [not null]
  created_at timestamp
  updated_at timestamp

  indexes {
    (user_id, smoked_on) [unique]
  }
}

Table user_schedules {
  id integer [pk, increment]
  user_id integer [not null]
  scheduled_smoking_time time [not null]
  label varchar
  is_active boolean [not null, default: true]
  created_at timestamp
  updated_at timestamp
}

Table user_schedule_reflections {
  id integer [pk, increment]
  user_schedule_id integer [not null]
  reflected_on date [not null]
  created_at timestamp
  updated_at timestamp

  indexes {
    (user_schedule_id, reflected_on) [unique]
  }
}

Table user_wishlists {
  id integer [pk, increment]
  user_id integer [not null]
  name varchar [not null]
  price integer [not null]
  memo text
  is_purchased boolean [not null, default: false]
  created_at timestamp
  updated_at timestamp
}

Table user_purchase_histories {
  id integer [pk, increment]
  user_wishlist_id integer [not null, unique]
  amount integer [not null]
  purchased_at timestamp [not null]
  created_at timestamp
  updated_at timestamp
}

Ref: user_settings.user_id - users.id
Ref: user_smoking_logs.user_id > users.id
Ref: user_schedules.user_id > users.id
Ref: user_schedule_reflections.user_schedule_id > user_schedules.id
Ref: user_wishlists.user_id > users.id
Ref: user_purchase_histories.user_wishlist_id - user_wishlists.id
```