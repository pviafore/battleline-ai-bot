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
    BattlelineEngine.start self, strategy
  end

  defp send_and_expect engine, message, expected do
    BattlelineEngine.send_command engine, message
    receive do
       {:message, message} -> assert message == expected
       _ -> assert false, "Invalid message received"
    end
  end

  defp check_state engine, expected_state do
    {:ok, state} = BattlelineEngine.get_state engine
    assert state == expected_state
  end


  def initial_state do
    %{direction: "", colors: []}
  end
  test "can check initial state" do
    engine = start_engine
    check_state engine, initial_state
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
     check_state engine, %{initial_state | direction: "north"}
  end

  test "state is updated with colors" do
    engine = start_engine
    BattlelineEngine.send_command engine, "colors 1 2 3 4 5 6"
    check_state engine, %{initial_state | colors: ["1", "2", "3", "4", "5", "6"]}
  end

end
