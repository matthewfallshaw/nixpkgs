task default: %w[install]

module Rake
  class FileTask < Task
    def name
      File.expand_path(@name)
    end
  end
end

def ep(name)
  return File.expand_path(name)
end

def slink(target, link)
  return FileUtils.ln_s(ep(target), ep(link))
end

SYMLINKS = {
  '~/.dotfiles_secrets' => '~/Google Drive/system/home/dotfiles_secrets',
  '~/CAD/' => '~/Documents/CAD/',
  '~/Google Drive/' => '~/Volumes/GoogleDrive/',
}
SYMLINKS.each do |l,t|
  file l => t do
    slink(t, l)
  end
end

MISSING_TARGETS = {
  '~/Google Drive/system/home/dotfiles_secrets' => "Is GDrive installed, and has it finished syncing?",
  '~/Documents/CAD/' => "Are you signed in to your AppleID and iCloud, and has it finished syncing?",
}
MISSING_TARGETS.each do |f,msg|
  file f do
    raise IOError.new("#{f} missing. #{msg}")
  end
end

task install: SYMLINKS.keys

# ~/code

directory '~/code'

# ~/
