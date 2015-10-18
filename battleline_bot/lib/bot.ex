defmodule Bot do
   def main(_) do

      outputter = CommandOutputter.start()
      strategy = DumbStrategy.start(outputter)
      engine = BattlelineEngine.start(strategy)
      run_input_loop( engine)
   end

   def run_input_loop(engine) do
      command = IO.gets ""
      BattlelineEngine.send_command(engine, command)
      run_input_loop( engine)
   end

end
