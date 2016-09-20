defmodule GameHelpersTest do
   use ExUnit.Case

   test "highest card of empty list is nil" do
      assert GameHelper.get_highest_card([]) == nil
   end

   test "can get highest card" do
      assert GameHelper.get_highest_card([{"r",1}, {"b", 5}]) == {"b", 5}
   end

   test "can convert card to string" do
      assert "b,2" == GameHelper.card_to_string({"b",2})
   end

   test "can get all cards" do
     cards = for color <- ["color1", "color2", "color3", "color4", "color5", "color6"], number <- 1..10, do: {color, number}
     assert cards == GameHelper.get_cards()
   end

   test "can get straight flush points" do
      assert 527 == GameHelper.get_formation_strength [{"r", 10}, {"r", 9}, {"r", 8}]
      assert 506 == GameHelper.get_formation_strength [{"b", 2}, {"b", 3}, {"b", 1}]
   end

    test "can get three of a kind points" do
       assert 427 == GameHelper.get_formation_strength [{"b", 9}, {"r", 9}, {"g", 9}]
       assert 403 == GameHelper.get_formation_strength [{"b", 1}, {"r", 1}, {"b", 1}]
    end

    test "can get flush points" do
       assert 316 == GameHelper.get_formation_strength [{"b", 9}, {"b", 6}, {"b", 1}]
       assert 304 == GameHelper.get_formation_strength [{"r", 1}, {"r", 1}, {"r", 2}]
    end

    test "can get straight points" do
       assert 224 == GameHelper.get_formation_strength [{"g", 9}, {"b", 8}, {"b", 7}]
       assert 206 == GameHelper.get_formation_strength [{"r", 1}, {"r", 3}, {"b", 2}]
    end

    test "can get host points" do
       assert 126 == GameHelper.get_formation_strength [{"g", 9}, {"b", 10}, {"b", 7}]
       assert 108 == GameHelper.get_formation_strength [{"r", 1}, {"r", 5}, {"b", 2}]
    end

    test "can get better formation" do
       assert [{"r", 10}, {"r", 9}, {"r", 8}] == GameHelper.get_better_formation [{"r", 10}, {"r", 9}, {"r", 8}], [{"b", 7}, {"b", 9}, {"b", 8}]
       assert [{"b", 1}, {"b", 2}, {"b", 3}] == GameHelper.get_better_formation [{"b", 1}, {"b", 2}, {"b", 3}], [{"r", 10}, {"g", 10}, {"b", 10}]
    end

    test "can get highest formation by hand" do
       assert [{"r", 8}, {"r", 9}, {"r", 10}] == GameHelper.get_highest_formation [{"r",1}, {"r", 2}, {"r",3},  {"r",8},  {"r",9},  {"r",10},  {"b",3}]
       assert [{"r", 8}, {"b", 8}, {"g", 8}] == GameHelper.get_highest_formation [{"r",1}, {"r", 8}, {"r",3},  {"b",8},  {"g",9},  {"r",7},  {"g",8}]
    end

    test "can get highest formation by hand with full flag" do
       assert [{"r", 1}, {"r", 2}, {"r", 3}] == GameHelper.get_highest_formation [{"r",1}, {"r", 2}, {"r",3}], [{"r",1}, {"r", 2}, {"r",3},  {"r",8},  {"r",9},  {"r",10},  {"b",3}]
    end

    test "can get highest formation by hand with one" do
       assert [{"r", 1}, {"r", 2}, {"r", 3}] == GameHelper.get_highest_formation [{"r",1},], [{"r", 2}, {"r",3},  {"r",8},  {"r",9},  {"r",10},  {"b",3}]
    end

    test "can get highest formation by hand with two" do
       assert [{"b", 9}, {"g", 9}, {"r", 9}] == GameHelper.get_highest_formation [{"b",9}, {"g", 9}], [{"r", 2}, {"r",3},  {"r",8},  {"r",9}, {"b",3}]
    end

    defp initial_state do
       %{claim: (for _ <- 1..9, do: "unclaimed"), flag_cards: (for _ <- 1..9, do: {[],[]}), direction: "north", hand: []}
    end

    defp add_hand state, hand do
       %{ state | :hand => hand}
    end

    defp claim state, flag, claimer do
      %{ state | :claim => List.replace_at(state.claim, flag, claimer)}
    end

    defp update_flag_state flag_cards, "north", cards do
        {cards, elem(flag_cards, 1)}
    end

    defp update_flag_state flag_cards, "south", cards do
        {elem(flag_cards, 0), cards}
    end

    defp place_cards state, direction, flag, cards do
        %{ state | :flag_cards => (List.replace_at(state.flag_cards, flag, update_flag_state(Enum.at(state.flag_cards, flag), direction, cards)))}

    end


    test "can select playable flags" do
        state = initial_state |> claim(3, "north") |> claim(7, "south") |> place_cards("north", 2, [{"r", 1}, {"r", 2}, {"r", 3}])
        assert GameHelper.get_playable_flags(state) == [0,1,4,5,6,8]
    end

    test "can get plays" do
        state = initial_state |> claim(3, "north") |> claim(7, "south") |> place_cards("north", 2, [{"color1", 1}, {"color1", 2}, {"color1", 3}]) |> add_hand( [{"color3", 1}, {"color4", 8}])
        assert GameHelper.get_plays(state) == [[0, {"color3", 1}], [0, {"color4", 8}], [1, {"color3", 1}], [1, {"color4", 8}], [4, {"color3", 1}], [4, {"color4", 8}], [6, {"color3", 1}], [6, {"color4", 8}]]
    end

    test "getting plays filters out automatic losses" do
        state = initial_state |> claim(3, "north") |> claim(7, "south")
        |> place_cards("north", 2, [{"color1", 1}, {"color1", 2}, {"color1", 3}])
        |> place_cards("south", 4, [{"color2", 7}, {"color2", 8}, {"color2", 9}])
        |> add_hand( [{"color3", 1}, {"color4", 8}])
        assert GameHelper.get_plays(state) == [[0, {"color3", 1}], [0, {"color4", 8}], [1, {"color3", 1}], [1, {"color4", 8}], [4, {"color4", 8}], [5, {"color3", 1}], [5, {"color4", 8}], [6, {"color3", 1}], [6, {"color4", 8}]]
    end

    test "can get enemy" do
        assert "south" = GameHelper.get_enemy "north"
        assert "north" = GameHelper.get_enemy "south"
    end

    test "get opponent's highest formation" do
        state = initial_state |> place_cards("north", 2, [{"color1", 1}, {"color1", 2}, {"color1", 3}])
        assert GameHelper.get_opponent_highest_formation(state, 1) == 527
        new_state = state |> add_hand( [{"color1", 10}, {"color2", 10}, {"color3", 10}, {"color4", 10}, {"color5", 10}, {"color6", 10}])
        assert GameHelper.get_opponent_highest_formation(new_state, 1) == 524

    end

    test "Get play with probability" do
        state = initial_state |> place_cards("north", 2, [{"color1", 1}, {"color1", 2}, {"color1", 3}]) |> add_hand( [{"color1", 10}, {"color2", 10}])
        assert GameHelper.get_play_with_probability(state, 527, [1, {"color1", 10}]) == [1, {"color1", 10}, 6.060606060606061e-4]
        assert GameHelper.get_play_with_probability(state, 527, [1, {"color1", 1}]) == [1, {"color1", 1}, 0]
    end

    test "Scratchpad" do
        state = initial_state
               |> add_hand( [{"color1", 1}, {"color2", 2}, {"color3", 7}, {"color2", 1}, {"color3", 4}, {"color3", 5}, {"color2", 3}])
               |> place_cards("north", 0, [{"color2", 5}, {"color4", 5}, {"color1", 5}])
               |> place_cards("south", 0, [{"color5", 10}, {"color5", 8}, {"color5", 1}])
               |> place_cards("north", 1, [{"color6", 9}, {"color6", 10}])
               |> place_cards("south", 1, [{"color3", 1}, {"color3", 3}, {"color3", 9}])
               |> place_cards("north", 2, [{"color2", 8}, {"color6", 8}])
               |> place_cards("south", 2, [{"color1", 6}, {"color2", 6}, {"color5", 6}])
               |> place_cards("north", 3, [{"color2", 9}])
               |> place_cards("south", 3, [{"color1", 10}, {"color3", 10}])
               |> place_cards("north", 4, [{"color5", 9}])
               |> place_cards("south", 4, [{"color6", 5}])
               |> place_cards("north", 5, [{"color5", 7}, {"color5", 2}])
        assert GameHelper.get_move(state) == [6, {"color2", 2}, 506.0]
    end

    test "Scratchpad 2" do
        state = initial_state
               |> add_hand( [{"color1", 4}, {"color1", 5}, {"color2", 1}, {"color3", 9}, {"color3", 5}, {"color2", 7}, {"color3", 2}])
               |> place_cards("north", 0, [{"color4", 8}])
               |> place_cards("south", 0, [{"color3", 10}, {"color3", 6}, {"color3", 4}])
               |> place_cards("south", 1, [{"color2", 8}])
               |> place_cards("north", 2, [{"color5", 10}, {"color5", 9}])
        assert GameHelper.get_move(state) == [1, {"color3", 9}, 316.0]
    end

end
