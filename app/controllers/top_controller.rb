class TopController < ApplicationController
  def index
    @files = Dir.entries("public/resources").delete_if{|a|a.start_with?(".")}
  end
end
