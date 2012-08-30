# -*- coding: utf-8 -*-

class TopController < ApplicationController
  def index
    # public/resources 以下からファイル名を全取得
    @files = Dir.entries("public/resources").delete_if{|a|a.start_with?(".")}

    # ファイル名からタグを取得
    @tags = {}
    @files.each do |file|
      @tags[file] = TaggedFile.where({:file_name => file}).map{|a|a.tag}
    end
    return unless params[:radio_param]

    # 検索(@filesを絞り込む)
    case params[:radio_param][:search_type]
    when "file"
      # ファイル名指定検索
      @files.select!{|file|file.include?(params[:keyword])}
    when "tag"
      # タグ指定検索
      tag_search params[:keyword]
    else
      # 何も無し
    end

  end

  private

  def tag_search pattern
    # patternを含むタグを持っているファイル名の配列を@filesに入れる
    selected_tag = TaggedFile.where("tag like '%#{pattern}%'")

    # タグが見つからない場合
    if selected_tag.empty?
      @files = []
      return
    end

    # 検索対象のタグを持ってるファイル名一覧を作る
    selected_tag.map!{|a|a.file_name}

    @files.select! do |file|
      return false if selected_tag.empty?
      selected_tag.include?(file)
    end
  end
end
