defmodule TestStrategy do
   def start name do
     {:ok, strategy} = Task.start_link(fn->recv(name) end)
     strategy
  end

  def recv name do
     receive do
        {:player_name, sender, direction} -> send sender, {:message, "player " <> direction <> " " <> name}
        {:play_card, sender, _} -> send sender, {:message, "play 1 b,2"}
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
    %{direction: "", colors: [], last_move: "", hand: [], claim: [], flag_cards: [{[],[]},{[],[]},{[],[]},{[],[]},{[],[]},{[],[]},{[],[]},{[],[]},{[],[]}] }
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

  def send_and_check_state message, field, expected do
    engine = start_engine
    BattlelineEngine.send_command engine, message
    new_state = put_in initial_state, [field], expected
    check_state engine, new_state
  end

  test "state is updated with colors" do
    send_and_check_state "colors 1 2 3 4 5 6", :colors, ["1", "2", "3", "4", "5", "6"]
    send_and_check_state "colors 6 5 4 3 2 1", :colors, ["6", "5", "4", "3", "2", "1"]
  end

  test "can get player cards" do
    send_and_check_state "player north hand r,1 r,2 r,3 r,4 r,5 r,6 r,7", :hand, [{"r", 1}, {"r", 2}, {"r", 3}, {"r", 4}, {"r", 5}, {"r", 6}, {"r", 7}]
  end

  test "can get flag claim status" do
    send_and_check_state "flag claim-status unclaimed north south unclaimed north south unclaimed north south", :claim, ["unclaimed", "north", "south", "unclaimed", "north", "south", "unclaimed", "north", "south"]
  end

  test "can get opponent play" do
     send_and_check_state "opponent play 1 r,2", :last_move, {1, {"r", 2}}
  end

  test "can request action" do
    engine = start_engine
    send_and_expect engine, "go play-card", "play 1 b,2"
  end

  test "can get flag-info" do
    engine = start_engine
    BattlelineEngine.send_command engine, "flag 1 cards north r,1"
    new_state = put_in initial_state, [:flag_cards], [{[{"r",1}],[]},{[],[]},{[],[]},{[],[]},{[],[]},{[],[]},{[],[]},{[],[]},{[],[]}]
    check_state engine, new_state
    BattlelineEngine.send_command engine, "flag 3 cards south r,3 b,3 g,5"
    newer_state = put_in new_state, [:flag_cards], [{[{"r",1}],[]},{[],[]},{[],[{"r",3}, {"b", 3}, {"g",5} ]},{[],[]},{[],[]},{[],[]},{[],[]},{[],[]},{[],[]}]
    check_state engine, newer_state
  end

end
