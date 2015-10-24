defmodule GameHelper do

  def get_highest_card([]), do: nil
  def get_highest_card(cards), do: Enum.max_by cards,&(elem &1, 1)

  def card_to_string({color, number}), do: color <> "," <> Integer.to_string(number)

  def get_cards(), do: for color <- ["color1", "color2", "color3", "color4", "color5", "color6"], number <- 1..10, do: {color, number}


end
