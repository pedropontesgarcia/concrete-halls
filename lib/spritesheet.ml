open Animations
open Tsdl_image.Image

type t = {
  filename : string;
  mutable rows : int;
  mutable cols : int;
  w : int;
  h : int;
  mutable row_start : int;
  mutable col_start : int;
  mutable col_end : int;
  mutable sprite_num_row : int;
  mutable sprite_num_col : int;
  mutable speed : int;
  mutable time : int;
}

let new_spritesheet filename rows cols w h row_start col_start col_end speed =
  {
    filename;
    rows;
    cols;
    w;
    h;
    row_start;
    col_start;
    col_end;
    sprite_num_row = row_start;
    sprite_num_col = col_start;
    speed;
    time = 0;
  }

let file_type file =
  let len_str = String.length file in
  if len_str < 3 then failwith "Invalid File"
  else
    let sub_str = String.sub file (len_str - 3) 3 in
    if sub_str = "ebp" then "webp"
    else if sub_str = ".xv" then "xv"
    else sub_str

let load_image r t = load_texture r t.filename |> Result.get_ok

let update_sprite_index sheet dt anim =
  sheet.time <- sheet.time + dt;
  if anim then
    if sheet.time > sheet.speed then (
      sheet.time <- 0;
      let row, col =
        if
          sheet.sprite_num_row = sheet.row_start + sheet.rows - 1
          && sheet.sprite_num_col = sheet.col_end
        then (sheet.row_start, sheet.col_start)
        else if sheet.sprite_num_col >= sheet.cols - 1 then
          (sheet.sprite_num_row + 1, (sheet.sprite_num_col + 1) mod sheet.cols)
        else (sheet.sprite_num_row, (sheet.sprite_num_col + 1) mod sheet.cols)
      in
      sheet.sprite_num_col <- col;
      sheet.sprite_num_row <- row;
      (row, col))
    else (sheet.sprite_num_row, sheet.sprite_num_col)
  else (0, 0)

let update_animations t animation check =
  if check then (
    t.rows <- get_rows animation;
    t.cols <- get_cols animation;
    t.row_start <- get_row_start animation;
    t.col_start <- get_col_start animation;
    t.sprite_num_col <- get_col_start animation;
    t.sprite_num_row <- get_row_start animation;
    t.speed <- get_speed animation;
    t.col_end <- get_col_end animation)
