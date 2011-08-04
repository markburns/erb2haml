require 'find'

RED_FG ="\033[31m"
GREEN_FG = "\033[32m"
END_TEXT_STYLE = "\033[0m"

# Helper method to inject ASCII escape sequences for colorized output
def color(text, begin_text_style)
  begin_text_style + text + END_TEXT_STYLE
end

namespace :haml do
  desc "Perform bulk conversion of all html.erb files to Haml in views folder then git mv file.erb to file.haml"
  task :destructive_convert_with_git do

    if `which html2haml`.empty?
      puts "#{color "ERROR: ", RED_FG} Could not find " +
         "#{color "html2haml", GREEN_FG} in your PATH. Aborting."
      exit(false)
    end

    puts "Looking for #{color "ERB", GREEN_FG} files to convert to " +
      "#{color("Haml", RED_FG)}..."

    Find.find("app/views/") do |path|
      if FileTest.file?(path) and path.downcase.match(/\.html\.erb$/i)
        haml_path = path.slice(0...-3)+"haml"

        unless FileTest.exists?(haml_path)
          print "Converting: #{path}... "

          if system("html2haml", path, haml_path)
            puts color("Done!", GREEN_FG)
            command = "mv #{haml_path} #{path}"
            system command

          else
            puts color("Failed!", RED_FG)
          end

        end

      end
    end
    system "git add app/views/**/*.erb"

    puts "Conversion complete, view the diff, commit, and then perform a rename to haml with\nrake haml:rename_files"

  end #End rake task


  desc "Rename files to haml files after conversion"

  task :rename_files do
    puts "Looking for #{color "ERB", GREEN_FG} files to rename to " +
      "#{color("Haml", RED_FG)}..."

    Find.find("app/views/") do |path|
      if FileTest.file?(path) and path.downcase.match(/\.html\.erb$/i)
        haml_path = path.slice(0...-3)+"haml"

        unless FileTest.exists?(haml_path)
          print "Moving: #{path}... "

          command = "git mv #{path} #{haml_path}"
          system command
        end
      end
    end
    puts "Renaming complete, you can commit the files or if you want to cancel:\ngit reset, or git git reset --hard HEAD^ to go back to the previous commit"
  end
end # End of :haml namespace

