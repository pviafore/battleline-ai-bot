defmodule GameHelper do

  def get_highest_card([]), do: nil
  def get_highest_card(cards), do: Enum.max_by cards,&(elem &1, 1)

  def card_to_string({color, number}), do: color <> "," <> Integer.to_string(number)

  def get_cards(), do: for color <- ["color1", "color2", "color3", "color4", "color5", "color6"], number <- 1..10, do: {color, number}

  defp is_straight(n1,n2,n3) do
     [sn1, sn2, sn3] = Enum.sort [n1,n2,n3]
     sn1 == sn2 - 1 and sn2 == sn3 - 1
  end

  def get_formation_strength([{color, n1}, {color, n2}, {color, n3}]) do
     cond do
         is_straight(n1,n2,n3) -> 500 + n1 + n2 + n3
         true -> 300 + n1 + n2 + n3
     end
  end
  def get_formation_strength([{_, num}, {_, num}, {_, num}]), do: 400 + num*3
  def get_formation_strength([{_, n1}, {_, n2}, {_, n3}]) do
    cond do
        is_straight(n1,n2,n3) -> 200 + n1 + n2 + n3
        true -> 100 + n1 + n2 + n3
    end
  end

end
