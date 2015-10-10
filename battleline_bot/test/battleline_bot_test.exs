defmodule BattlelineBotTest do
  use ExUnit.Case

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "can check initial state" do
    engine = GameEngine.start
    {:ok, state} = GameEngine.get_state engine
    assert state == %{}
  end
end
