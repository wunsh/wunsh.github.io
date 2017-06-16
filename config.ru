require "rack/contrib/try_static"
require_relative "lib/not_found"

use Rack::TryStatic,
    root: "_site",
    urls: %w(/),
    try: %w(index.html /index.html)

run NotFound
