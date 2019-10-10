class HomesController < ApplicationController
  def show
    render json: intro_message, status: :ok
  end

  private

  def intro_message
    {
      status: :ok,
      author: "Ribose Inc.",
      message: "This is an API only application",

      links: {
        github: "https://github.com/relaton/api.relaton.org",
        documentation: "https://github.com/relaton/api.relaton.org/wiki",
      }
    }
  end
end
