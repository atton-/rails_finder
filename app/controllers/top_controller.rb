# -*- coding: utf-8 -*-

class TopController < ApplicationController
  def index

    # params[:radio_param]が無いなら、全てのデータを表示
    if params[:radio_param].nil?
      @files = TaggedFile.resources_list
      @tags = TaggedFile.collect_tags @files
      return
    end

    # 検索(@filesを絞り込む)
    case params[:radio_param][:search_type]
    when "file"
      # ファイル名指定検索
      @files = TaggedFile.file_name_search params[:keywords]
      @tags = TaggedFile.collect_tags @files
    when "tag"
      # タグ指定検索
      @files = TaggedFile.tag_search params[:keywords]
      @tags = TaggedFile.collect_tags @files
    else
      # 何も無し
    end
  end

end
