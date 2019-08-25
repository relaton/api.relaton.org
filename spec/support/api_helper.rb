module ApiHelpers
  def get_api(endpoint, params = {}, headers = {})
    get endpoint, params: params, headers: headers.merge(auth_headers)
  end

  def auth_headers
    {}
  end
end
