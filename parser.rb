module Parser
  module Tokenizer
    TOKENS = {
      :is => :token_is,
      :command => :token_command,
      :var => :token_variable,
      :int => :token_integer,
      :float => :token_float,
      :bool => :token_boolean,
      :comment => :token_comment,
      :end => :token_endstatement,
      :statement => :token_statement,
      :newline => :token_endline,
      :if => :token_if,
      :else => :token_else,
      :string => :token_string,
      :string_mark => :token_string_mark,
      :constant => :token_constant,
    }
    KEYWORDS = {
      "if" => TOKENS[:if],
      "else" => TOKENS[:else],
    }

    COMMANDS = %w[
      say
      switch
      variable
      self_switch
      input_number
      wait
      exit
      erase
      common_event
      label
      jump
      items
      timer
      weapons
      armor
      party
      windowskin
      battle_bgm
      battle_endme
      save_access
      menu_access
      encounter
      transfer
      move_event
      scroll
      map_settings
      fog_tone
      fog_opacity
      animation
      transparent
      wait_for_move
      prepare_for_transition
      transition
      screen_tone
      flash
      shake
      picture
      move_picture
      rotate_picture
      tint_picture
      erase_picture
      weather
      bgm
      bgs
      fade_bgm
      fade_bgs
      memorize_sound
      restore_sound
      me
      se
      stop_se
      battle
      shop
      name_input
      hp
      sp
      state
      recover_all
      exp
      level
      parameters
      skills
      equipment
      actor_name
      actor_class
      actor_graphic
      enemy_hp
      enemy_sp
      enemy_state
      recover_enemy
      enemy_appearance
      enemy_transform
      show_battle_animation
      deal_damage
      force_action
      abort_battle
      call_menu
      call_save
      gameover
      return_title
      eval
    ]

    class << self
      def tokenize(string)
        tokens = {}
        line_number = 0
        # Iterate through each line
        in_string = false
        string.each_line do |line|
          line.strip!
          # Add a newline as a terminator
          line += "\n"
          line_tokens = []

          current_token = ""
          comment = false
          previous_char = ""
          end_statement = false
          # Iterate through each character
          line.each_char do |char|
            current_token << char
            # Set string flag if we're in a string
            if char == '"' && previous_char != '\\'
              in_string = !in_string
            end
            if current_token == ">>" && previous_char == '\\'
              comment = true
            end
            if current_token == "end"
              end_statement = true
            end

            # Assemble the token until we reach a space, marking the end of the token, or we're in a string
            next unless (char == " " && !in_string && !comment && !end_statement) or char == "\n"
            # Remove the space because we don't need it anymore
            current_token.strip!

            if COMMANDS.include?(current_token)
              line_tokens << [TOKENS[:command], current_token]
              current_token = ""
              next
            end

            # Figure out what the hell the token is
            case current_token
            when "is" || "are"
              line_tokens << [TOKENS[:is], current_token]
              current_token = ""
              next
            when /\Aend \w*\z/
              line_tokens << [TOKENS[:end], current_token]
              current_token = ""
              next
            when /\$\w*/
              line_tokens << [TOKENS[:statement], current_token]
              current_token = ""
              next
            when "if"
              line_tokens << [TOKENS[:if], current_token]
              current_token = ""
              next
            when "else"
              line_tokens << [TOKENS[:else], current_token]
              current_token = ""
              next
            when /(on|off|true|false)/
              line_tokens << [TOKENS[:bool], current_token]
              current_token = ""
              next
            when /\A\d*\z/
              line_tokens << [TOKENS[:int], current_token]
              current_token = ""
              next
            when /\A\d*\.\d*\z/
              line_tokens << [TOKENS[:float], current_token]
              current_token = ""
              next
            when />>.*\z/
              line_tokens << [TOKENS[:comment], current_token]
              current_token = ""
              comment = false
              next
            when /".*"/
              line_tokens << [TOKENS[:string_mark], '"']
              line_tokens << [TOKENS[:string], current_token]
              line_tokens << [TOKENS[:string_mark], '"']
              current_token = ""
              next
            end

            if current_token.upcase == current_token
              line_tokens << [TOKENS[:constant], current_token]
              current_token = ""
              next
            end

            if in_string && current_token.match(/.*"/)
              line_tokens << [TOKENS[:string_mark], '"']
              line_tokens << [TOKENS[:string], current_token]
              current_token = ""
              next
            end

            if !in_string && current_token.match(/".*/)
              line_tokens << [TOKENS[:string], current_token]
              line_tokens << [TOKENS[:string_mark], '"']
              current_token = ""
              next
            end

            line_tokens << [TOKENS[:var], current_token]
            current_token = ""
            previous_char = char
          end
          line_tokens << [TOKENS[:newline], "\n"]
          tokens[line_number] = line_tokens
          line_number += 1
        end
        return tokens
      end
    end
  end
end

code = File.read("example_event.baba")

require "ap"

ap Parser::Tokenizer.tokenize(code)
