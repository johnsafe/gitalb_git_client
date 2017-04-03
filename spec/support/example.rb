#add benchmark to lib/rspec/core/example.rb
module RSpec
  module Core
    class Example
      def run(example_group_instance, reporter)
        @example_group_instance = example_group_instance
        @example_group_instance.example = self

        start(reporter)

        begin
          unless pending
            with_around_each_hooks do
              begin
                run_before_each

                time = Benchmark.realtime do
                  @example_group_instance.instance_eval(&@example_block)
                end
                puts "#{self.description} cost #{time}s." unless self.description=~/example at/
              rescue Pending::PendingDeclaredInExample => e
                @pending_declared_in_example = e.message
              rescue Exception => e
                set_exception(e)
              ensure
                run_after_each
              end
            end
          end
        rescue Exception => e
          set_exception(e)
        ensure
          @example_group_instance.instance_variables.each do |ivar|
            @example_group_instance.instance_variable_set(ivar, nil)
          end
          @example_group_instance = nil

          begin
            assign_generated_description
          rescue Exception => e
            set_exception(e, "while assigning the example description")
          end
        end

        finish(reporter)
      end
    end
  end
end
