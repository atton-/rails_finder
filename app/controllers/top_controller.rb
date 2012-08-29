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
  end
end
