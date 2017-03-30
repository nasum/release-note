def __main__(argv)
  opts = Getopts.getopts(
    'r:d',
    't:d',
    '--version'
  )

  repo = opts['r'] || 'nasum/release-note'

  type = if opts['t'] == 'issue'
    'issues'
  elsif opts['t'] == 'pull-request'
    'pulls'
  else
    'issues'
  end

  curl = Curl.new

  headers = {
    'User-Agent' => 'release-note'
  }

  response = curl.get("https://api.github.com/repos/#{repo}/#{type}?access_token=#{ENV['GITHUB_ACCESS_TOKEN']}&state=close", headers)

  puts "##{repo}"

  JSON::parse(response.body).each do |pr|
    doc = <<-"EOS"
## #{pr['title']}"
#{pr['body']}
#{pr['closed_at']}
    EOS

    puts doc
  end
end
