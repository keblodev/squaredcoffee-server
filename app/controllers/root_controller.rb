class RootController < ApplicationController

  def index
  end

  def js
    render layout: "js"
  end

  def react
    render layout: "react"
  end

end
