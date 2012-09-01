# -*- coding: utf-8 -*-

class TaggedFile < ActiveRecord::Base
  attr_accessible :file_name, :tag

  # ファイル名は必ず入力
  validates :file_name, :presence => true

  # タグも必ず入力
  # 加えてファイル名+タグの組み合わせは重複を許さない
  validates :tag, :presence => true, :uniqueness => {:scope => [:file_name,:tag]}


  # TaggedFileのクラスメソッド
  def self.resources_list
    # public/resources 以下のファイル名をすべて返す
    Dir.entries("public/resources").delete_if{|a|a.start_with?(".")}
  end

  def self.collect_tags files
    # files 全てに対応した(file_name=>tagの配列)のハッシュを返す

    return {} if files.nil?

    all_tag = TaggedFile.all

    tags = {}
    files.each do |file|
      tags[file] = all_tag.select{|a|a.file_name == file}.map{|a|a.tag}
    end
    tags
  end

  def self.file_name_search patterns
    # patterns を全て含むファイル名の配列を返す
    # patterns はスペースで区切られた検索patternの文字列を想定
    resources_list.select do |file|
      patterns.split(" ").all? do |pattern|
        file.include? pattern
      end
    end
  end

  def self.tag_search patterns
    # patterns を全て含むタグを持っているファイル名の配列を返す
    # patterns はスペースで区切られた検索patternの文字列を想定

    # pattern にマッチするリストを全部取得
    pattern_matched_files_list = patterns.split(" ").map do |pattern|
      TaggedFile.select("distinct file_name").where("tag like '%#{pattern}%'")
    end
    pattern_matched_files_list.map!{|list|list.map!{|file|file.file_name}}

    # 全てのpatternsをtagsに持つファイルのみ残す。(配列の積を使ってる)
    all_files = TaggedFile.select("distinct file_name").map{|a|a.file_name}
    patterns_matched_files = pattern_matched_files_list.inject(all_files){|all,n|all & n}

    # patternを含むタグが見つからない場合は空の配列を返す
    return [] if patterns_matched_files.empty?

    # タグを持っているファイル名のみ配列に残す
    files = resources_list
    return [] if files.empty?
    files.select! do |file|
      patterns_matched_files.any?{|tag| tag.include?(file)}
    end
    files
  end
end
