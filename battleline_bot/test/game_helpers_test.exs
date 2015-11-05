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
       %{claim: (for _ <- 1..9, do: "unclaimed"), flag_cards: (for _ <- 1..9, do: {[],[]}), direction: :north, hand: []}
    end

    defp add_hand state \\ initial_state, hand do
       %{ state | :hand => hand}
    end

    defp claim state, flag, claimer do
      %{ state | :claim => List.replace_at(state.claim, flag, claimer)}
    end

    test "can pick best flag with best card from best formation given a hand" do
       assert {2, {"r", 10}} == GameHelper.get_move add_hand([{"b",9}, {"y", 9}, {"r", 2}, {"r",3},  {"g",8},  {"r",10}, {"b",3}])
       assert {2, {"b", 9}} == GameHelper.get_move add_hand([{"b",9}, {"y", 9}, {"r", 2}, {"r",3},  {"g",8},  {"y",5}, {"b",3}])
    end

    test "can pick best flag with best card from best formation given a hand when flag is claimed" do
       state = claim initial_state, 2, :north
       assert {3, {"r", 10}} == GameHelper.get_move add_hand(state, [{"b",9}, {"y", 9}, {"r", 2}, {"r",3},  {"g",8},  {"r",10}, {"b",3}])
    end

    defp update_flag_state flag_cards, :north, cards do
        {cards, elem(flag_cards, 1)}
    end

    defp update_flag_state flag_cards, :south, cards do
        {elem(flag_cards, 0), cards}
    end

    defp place_cards state, direction, flag, cards do
        %{ state | :flag_cards => (List.replace_at(state.flag_cards, flag, update_flag_state(Enum.at(state.flag_cards, flag), direction, cards)))}

    end

    test "can pick best flag when first flag is full" do
        state = place_cards initial_state, :north, 2, [{"r", 1}, {"r", 2}, {"r", 3}]
        assert {3, {"r", 10}} == GameHelper.get_move add_hand(state, [{"b",9}, {"y", 9}, {"r", 2}, {"r",3},  {"g",8},  {"r",10}, {"b",3}])
    end

    test "can pick flag with best chance" do
           state = place_cards initial_state, :north, 3, [{"r", 1}, {"r", 2}]
           assert {3, {"r", 3}} == GameHelper.get_move add_hand(state, [{"b",9}, {"y", 9}, {"r", 2}, {"r",3},  {"g",8},  {"r",10}, {"b",3}])
           assert {2, {"b", 10}} == GameHelper.get_move add_hand(state, [{"b",9}, {"y", 9}, {"z", 2}, {"z",3},  {"g",8},  {"b",10}, {"b",3}])
    end

    test "will pick a flag that has two neighbors over best flag" do
      state = initial_state |> claim(6, :north) |> claim(7, :north) |> add_hand([{"b",9}, {"y", 9}, {"r", 2}, {"r",3},  {"g",8},  {"r",10}, {"b",3}])
      assert {5, {"r", 10}} == GameHelper.get_move state
      new_state = state |> claim(0, :north) |> claim(2, :north) |> claim(5, :south)
      assert {1, {"r", 10}} == GameHelper.get_move new_state

    end
end
