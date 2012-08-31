# -*- coding: utf-8 -*-

class TaggedFile < ActiveRecord::Base
  attr_accessible :file_name, :tag

  # ファイル名は必ず入力
  validates :file_name, :presence => true

  # タグも必ず入力
  # 加えてファイル名+タグの組み合わせは重複を許さない
  validates :tag, :presence => true, :uniqueness => {:scope => [:file_name,:tag]}

end

# TaggedFileのクラスメソッド
def TaggedFile.resources_list
  # public/resources 以下のファイル名をすべて返す
  Dir.entries("public/resources").delete_if{|a|a.start_with?(".")}
end

def TaggedFile.collect_tags files
  # files 全てに対応した(file_name=>tagの配列)のハッシュを返す

  return {} if files.nil?

  all_tag = TaggedFile.all

  tags = {}
  files.each do |file|
    tags[file] = all_tag.select{|a|a.file_name == file}.map{|a|a.tag}
  end
  tags
end

def TaggedFile.file_name_search patterns
  # patterns を全て含むファイル名の配列を返す
  # patterns はスペースで区切られた検索patternの文字列を想定
  resources_list.select do |file|
    patterns.split(" ").all? do |pattern|
      file.include? pattern
    end
  end
end

def TaggedFile.tag_search patterns
  # patterns を全て含むタグを持っているファイル名の配列を返す
  # patterns はスペースで区切られた検索patternの文字列を想定

  condition = patterns.split(" ").map{|pattern|"tag like '%#{pattern}%'"}.join(" and ")
  selected_tag = TaggedFile.select("distinct file_name").where(condition)

  # patternを含むタグが見つからない場合は空の配列を返す
  return [] if selected_tag.empty?

  # patternを含むタグを持っているファイル名配列を作る
  selected_tag.map!{|a|a.file_name}

  # タグを持っているファイル名のみ配列に残す
  files = resources_list
  return [] if files.empty?

  files.select! do |file|
    selected_tag.include?(file)
  end
  files
end
