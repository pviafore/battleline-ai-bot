defmodule BattlelineBotTest do
  use ExUnit.Case

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "can check invalid messages to parser" do
    engine = GameEngine.start
  end
end
