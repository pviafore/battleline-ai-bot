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
     assert cards = GameHelper.get_cards()
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
end
