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

    # 検索(@filesを絞り込む)
    case params[:search_type]
    when "file"
      # ファイル名指定
      @files.select!{|file|file.include?(params[:keyword])}
    when "tag"
      # タグ指定
      selected_tag = @tags.select do |file,tags|
        tags.any? do |tag|
          tag.include?(params[:keyword])
        end 
      end 
      @files.select!{|file|selected_tag.keys.include?(file)}
    else
      # 何も無し
    end

  end
end
