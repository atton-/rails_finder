# -*- coding: utf-8 -*-

class TopController < ApplicationController
  def index

    # params[:radio_param]が無いなら、全てのデータを表示
    if params[:radio_param].nil?
      @files = resources_list
      @tags = collect_tags @files
      return
    end

    # 検索(@filesを絞り込む)
    case params[:radio_param][:search_type]
    when "file"
      # ファイル名指定検索
      @files.select!{|file|file.include?(params[:keyword])}
      @tags = collect_tags @files
    when "tag"
      # タグ指定検索
      @files = tag_search params[:keyword]
      @tags = collect_tags @files
    else
      # 何も無し
    end
  end

  private

  def resources_list
    # public/resources 以下のファイル名をすべて返す
    Dir.entries("public/resources").delete_if{|a|a.start_with?(".")}
  end

  def collect_tags files
    # files 全てから(file_name=>tagの配列)のハッシュを返す

    return {} if files.nil?

    tags = {}
    files.each do |file|
      tags[file] = TaggedFile.where({:file_name => file}).map{|a|a.tag}
    end
    tags
  end

  def tag_search pattern
    # patternを含むタグを持っているファイル名の配列を返す
    selected_tag = TaggedFile.where("tag like '%#{pattern}%'")

    # タグが見つからない場合
    return [] if selected_tag.empty?

    # 検索対象のタグを持ってるファイル名配列を作る
    selected_tag.map!{|a|a.file_name}

    # タグを持ってるファイル名配列に存在ものだけ残す
    files = resources_list
    return [] if files.empty?

    files.select! do |file|
      selected_tag.include?(file)
    end
    files
  end

end
