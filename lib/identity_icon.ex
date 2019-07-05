defmodule IdentityIcon do
  @moduledoc """
  Documentation for IdentityIcon.
  """

  def main(input) do
    input
    |> hash_input
    |> create_color
    |> create_table
    |> remove_odd
    |> build_pixel
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %IdentityIcon.Image{hex: hex}
  end

  def create_color(%IdentityIcon.Image{hex: [r,g,b | _tail]} = image) do
    %IdentityIcon.Image{image | color: {r,g,b}}
  end

  def create_table(%IdentityIcon.Image{hex: hex} = image) do
    grid = hex
    |> Enum.chunk_every(3, 3, :discard)
    |> Enum.map(&reflect_table/1)
    |> List.flatten
    |> Enum.with_index

    %IdentityIcon.Image{image | grid: grid}
  end

  def reflect_table(row) do
    [f, s | _tail] = row
    row ++ [f, s]
  end

  def remove_odd(%IdentityIcon.Image{grid: grid} = image) do
    new_grid = Enum.filter(grid, fn {v, _i} -> rem(v, 2) == 0 end)
    %IdentityIcon.Image{image | grid: new_grid}
  end

  def build_pixel(%IdentityIcon.Image{grid: grid} =  image) do
    pixel_map = Enum.map(grid, fn {_v, i} -> calc_side(i) end )
    %IdentityIcon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%IdentityIcon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn{start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end
    :egd.render(image)
  end

  # auxiliary functions
  def calc_side(index) do
    h = rem(index, 5) * 50
    v = div(index, 5) * 50
    top_left = {h, v}
    bottom_right = {h+50, v+50}
    {top_left, bottom_right}
  end
end
