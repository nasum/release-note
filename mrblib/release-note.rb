def __main__(argv)
  opt = Getopts.getopts(
    'r:d',
    'version'
  )

  repo = opt['r']

  curl = Curl.new

  headers = {
    'User-Agent' => 'release-note'
  }

  response = curl.get("https://api.github.com/repos/#{repo}/pulls?access_token=#{ENV['GITHUB_ACCESS_TOKEN']}&state=close", headers)

  JSON::parse(response.body).each do |pr|
    puts "## #{pr['title']}"
    puts pr['body']
    puts pr['closed_at']
  end
end
