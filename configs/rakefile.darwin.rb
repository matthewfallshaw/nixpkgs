task default: %w[install]

# Symlink, error if link exists
SYMLINKS = {
  '~/.hammerspoon' => '~/code/hammerspoon-config',
  # '~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/com.matthewfallshaw.chrometabsfinder.json' =>
  #   '~/code/chrome-tabs-finder/native-messaging-host/com.matthewfallshaw.chrometabsfinder.json',
  # '~/bin/chrome-client' => '~/code/chrome-tabs-finder/native-messaging-host/client.py',
}
# Symlink, overwrite if link exists
SYMLINKS_FORCED = {
  '~/.config/karabiner' => '~/code/dotfiles/config/karabiner',
  '~/Library/Application Support/Quicksilver' => '~/Google Drive/system/Library/Application Support/Quicksilver',
  '~/Library/Application Support/Typinator' => '~/Google Drive/system/Library/Application Support/Typinator',
  '~/Library/Application Support/Keycue' => '~/Google Drive/system/Library/Application Support/Keycue',
  '~/Library/Application Support/nvALT' => '~/Google Drive/system/Library/Application Support/nvALT',
  '~/Library/Application Support/SuperSlicer' => '~/Google Drive/system/Library/Application Support/SuperSlicer',
  '~/Library/Application Support/Dash' => '~/Google Drive/system/Library/Application Support/Dash',
}
COPY = {
}
# Error if target is missing
GDRIVE_ERROR = "Is GDrive installed, and has it finished syncing?"
MISSING_TARGETS = {
  '~/code/chrome-tabs-finder/native-messaging-host/com.matthewfallshaw.chrometabsfinder.json' => 'Try https://github.com/matthewfallshaw/chrome-tabs-finder',
}
SYMLINKS_FORCED.select {|t,s| s.match?(%r{^~/Google Drive/})}.each do |t,s|
  MISSING_TARGETS[s] = GDRIVE_ERROR
end

module Rake
  class FileTask < Task
    def name
      File.expand_path(@name)
    end
  end

  class SymlinkTask < FileTask
    def needed?
      !File.symlink?(name) || @application.options.build_all
    end
  end

  module DSL
    def symlinkTask(*args, &block) # :doc:
      Rake::SymlinkTask.define_task(*args, &block)
    end
  end

end

def ep(name)
  return File.expand_path(name)
end

def slink(target, link)
  return FileUtils.ln_s(ep(target), ep(link))
end

SYMLINKS.each do |l,t|
  desc "file task for #{l} (symlink to #{t})"
  file l => t do
    slink(t, l)
  end
end

SYMLINKS_FORCED.each do |l,t|
  desc "Symlink symlinkTask task for #{l} => #{t}"
  symlinkTask l => t do
    remove_dir(ep(l)) if File.exist?(ep(l))
    slink(t, l)
  end
end

MISSING_TARGETS.each do |f,msg|
  desc "file task for #{f} (error if required)"
  file f do
    raise IOError.new("#{f} missing. #{msg}")
  end
end

desc "install everything"
task install: SYMLINKS.keys + SYMLINKS_FORCED.keys + COPY.keys

directory '~/code'

desc 'file task for ~/code/hammerspoon-config (git clone)'
file '~/code/hammerspoon-config' => '~/code' do
  sh('git clone git@github.com:matthewfallshaw/hammerspoon-config.git ~/code/hammerspoon-config')
end

file '~/code/dotfiles/config/karabiner' => '~/code/dotfiles'

desc 'file task for ~/code/dotfiles (git clone)'
file '~/code/dotfiles' => '~/code' do |t|
  if !File.exist?(t.name)
    sh('git clone git@github.com:matthewfallshaw/dotfiles.git ~/code/dotfiles')
  end
end
