# frozen_string_literal: true

module Save
  def save_prompt
    save = YAML.dump(self)
    Dir.mkdir('saves') unless File.exist?('saves')
    current_saves = Dir.children('saves').sort
    save_number = if current_saves.count < 5
                    current_saves.count + 1
                  else
                    1
                  end

    if current_saves.count == 5
      overwrite_prompt(current_saves, save)
    else
      puts 'Enter the name for your new save. Or type "overwrite" to select a slot to overwrite.'
      save_choice = gets.chomp

      if save_choice == 'overwrite'
        if current_saves.empty?
          puts 'No saves present!'
          save_prompt
        else
          overwrite_prompt(current_saves, save)
        end
      else
        save_game(save_number, save_choice, save)
      end
    end
  end

  def save_game(number, name, save)
    puts 'Saving...'
    File.open("saves/#{number}. #{name}.txt", 'w') do |file|
      file.write(save)
    end
    puts 'Successfully saved.'
  end

  def overwrite_prompt(current_saves, save)
    overwrite_hint = 'Please select the save file number you would like to overwrite.'
    puts overwrite_hint
    puts current_saves
    overwrite_number = gets.chomp

    until ('1'..current_saves.count.to_s).to_a.include?(overwrite_number)
      puts overwrite_hint
      overwrite_number = gets.chomp
    end

    puts 'Enter the name for your new save.'
    overwrite_name = gets.chomp

    save_overwrite(current_saves, overwrite_number, overwrite_name, save)
  end

  def save_overwrite(current_saves, number, name, save)
    puts 'Saving...'
    File.open("saves/#{current_saves[number.to_i - 1]}", 'w') do |file|
      file.write(save)
    end
    File.rename("saves/#{current_saves[number.to_i - 1]}", "saves/#{number}. #{name}")
    puts 'Successfully saved.'
  end
end
