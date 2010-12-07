require 'rails'

module EcoAppsSupport

  class Railtie < Rails::Railtie
    initializer "copy_static_file" do
      path = File.join(File.dirname(__FILE__),"files", "assets")

      Dir["#{path}/*"].each do |dir|
        FileUtils.cp_r(dir, Rails.root.join("public"))
      end

      gitignore = Rails.root.join(".gitignore")
      existing = File.open(gitignore, 'r').readlines.map(&:strip)
      
      Dir["#{path}/*"].map{|dir|
        base = File.basename(dir)
        Dir["#{dir}/*"].map{|file| "public/#{base}/#{File.basename(file)}"}
      }.flatten.each do |file|
        existing << file unless existing.include?(file)
      end

      File.open(gitignore, 'w'){|f| f.write(existing.join("\n"))}
    end

    initializer "require_ajax_render" do
      require File.join(File.dirname(__FILE__),"helpers/ajax_render")
    end
    
  end

end
