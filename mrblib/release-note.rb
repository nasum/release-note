def __main__(argv)
  opts = Getopts.getopts(
    'r:t:f:v',
    'repository',
    'type',
    'issue',
    'pull-request',
    'version'
  )

  if opts.include?('v') || opts.include?('version')
    puts "release-note:#{ReleaseNote::VERSION}"
  else
    repo = opts['r'] || 'nasum/release-note'

    type = if opts.include?('issue')
      'issues'
    elsif opts.include?('pull-request')
      'pulls'
    else
      'issues'
    end

    from = opts['f'] || (Time.new - 60 * 60 * 24 * 7).strftime("%Y-%m-%dT%H:%M:%SZ")
    curl = Curl.new

    headers = {
      'User-Agent' => 'release-note'
    }

    flg = true
    count = 1
    doc = []

    loop do
      url = "https://api.github.com/repos/#{repo}/#{type}?access_token=#{ENV['GITHUB_ACCESS_TOKEN']}&state=close&since=#{from}&page=#{count}"
      body = JSON::parse(curl.get(url, headers).body)

      break if body.size == 0

      body.select{ |obj| obj['closed_at'] != nil }.each do |pr|
        doc << "#{pr['closed_at']}：#{pr['title']}"
      end
      count += 1
    end

    puts doc.join('\\n')
  end
end
