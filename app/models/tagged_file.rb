# -*- coding: utf-8 -*-

class TaggedFile < ActiveRecord::Base
  attr_accessible :file_name, :tag

  # ファイル名は必ず入力
  validates :file_name, :presence => true

  # タグも必ず入力
  # 加えてファイル名+タグの組み合わせは重複を許さない
  validates :tag, :presence => true, :uniqueness => {:scope => [:file_name,:tag]}
end
