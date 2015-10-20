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
end
