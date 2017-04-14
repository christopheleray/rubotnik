module Rubotnik
  # Routing for messages
  class MessageDispatch
    include Commands

    def initialize(message)
      @message = message
      p @message.class
      p @message
      @user = UserStore.instance.find_or_create_user(@message.sender['id'])
    end

    def route(&block)
      if @user.current_command
        command = @user.current_command
        execute(command)
        puts "Command #{command} is executed for user #{@user.id}" # log
      else
        bind_commands(&block)
      end
    end

    private

    def bind_commands(&block)
      @matched = false
      instance_eval(&block)
    end

    def greet(with: 'Hello')
      return if @user.greeted?
      if block_given?
        yield
      else
        say with
      end
      @user.greet
    end

    def bind(*regex_strings, all: false, to: nil, start_thread: {})
      regexps = regex_strings.map { |rs| /#{rs}/i }
      proceed = regexps.any? { |regex| @message.text =~ regex }
      proceed = regexps.all? { |regex| @message.text =~ regex } if all
      return unless proceed
      @matched = true
      if block_given?
        yield
        return
      end
      handle_command(to, start_thread)
    end

    def handle_command(to, start_thread)
      if start_thread.empty?
        execute(to)
        @user.reset_command
      else
        # say definition is located in Helpers module mixed into bot.rb 
        say(start_thread[:message], quick_replies: start_thread[:quick_replies])
        @user.set_command(to)
      end
    end

    def unrecognized
      return if @matched
      puts 'None of the commands were recognized' # log
      yield
      @user.reset_command
    end

    def execute(command)
      method(command).call
    end
  end
end