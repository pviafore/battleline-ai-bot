defmodule TestStrategy do
   def start name do
     {:ok, strategy} = Task.start_link(fn->recv(name) end)
     strategy
  end

  def recv name do
     receive do
        {:player_name, sender, direction} -> send sender, {:message, "player " <> direction <> " " <> name}
        _ -> nil
     end
     recv name
  end

end

defmodule BattlelineBotTest do
  use ExUnit.Case

  defp start_engine name \\ "TestBot" do
    strategy = TestStrategy.start name
    GameEngine.start self, strategy
  end

  defp send_and_expect engine, message, expected do
    GameEngine.send_command engine, message
    receive do
       {:message, message} -> assert message == expected
       _ -> assert false, "Invalid message received"
    end
  end

  defp check_state engine, expected_state do
    {:ok, state} = GameEngine.get_state engine
    assert state == expected_state
  end

  test "the truth" do
    assert 1 + 1 == 2
  end


  test "can check initial state" do
    engine = start_engine
    check_state engine, %{direction: ""}
  end

  test "can request player name" do
    engine = start_engine
    send_and_expect engine, "player north name", "player north TestBot"
    send_and_expect engine, "player south name", "player south TestBot"
  end

  test "requesting player name goes to strategy" do
    engine = start_engine "NewName"
    send_and_expect engine, "player north name", "player north NewName"
  end

  test "state is updated with direction when player name is given" do
       engine = start_engine
       send_and_expect engine, "player north name", "player north TestBot"
       check_state engine, %{direction: "north"}

  end
end
