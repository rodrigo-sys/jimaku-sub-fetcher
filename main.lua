local utils = require 'mp.utils'

-- Config
local API_KEY = os.getenv("JIMAKU_API_KEY")
local OSD_TIMEOUT = 3

-- API
local function search(title)
  local args = {
    "curl", "-s",
    "-H", "Authorization: " .. API_KEY,
    "-G", "--data-urlencode", "query=" .. title,
    "https://jimaku.cc/api/entries/search"
  }
  local result = utils.subprocess({ args = args, capture_stdout = true })
  local entries = utils.parse_json(result.stdout)
  if entries and #entries > 0 then
    return entries
  end
  return nil
end

local function get_files(entry_id, episode)
  local args = {
    "curl", "-s",
    "-H", "Authorization: " .. API_KEY,
    "https://jimaku.cc/api/entries/" .. entry_id .. "/files?episode=" .. episode
  }
  local result = utils.subprocess({ args = args, capture_stdout = true })
  local files = utils.parse_json(result.stdout)
  if files and #files > 0 then
    return files
  end
  return nil
end

-- Download
local function download(url, dest_path)
  utils.subprocess({
    args = { "curl", "-s", "-o", dest_path, url }
  })
end

-- Helpers
local function parseFilename(filename)
  local result = utils.subprocess({
    args = { "guessit", '-j', filename },
    capture_stdout = true
  })

  local data = utils.parse_json(result.stdout)
  return data
end

local function buildSubtitlePath(filename, file_url)
  local path = mp.get_property('path')
  local video_dir = path:match("(.*/)") or "./"

  local ext = file_url:match("%.([^%.]+)$") or "srt"
  local base_name = filename:match("^([^%.]+)") or filename

  return video_dir .. base_name .. "." .. ext
end

local function syncSubtitles(sub_path, video_path)
  video_path = video_path or mp.get_property('path')
  local args = { "ffsubsync", video_path, "-i", sub_path, "-o", sub_path }
  utils.subprocess({ args = args })
end

-- Main
local function main()
  -- parse filename to get title and episode
  mp.osd_message("Jimaku: parsing file name", OSD_TIMEOUT)
  local filename = mp.get_property('filename')
  local info = parseFilename(filename)
  local title, episode = info.title, info.episode

  -- search for title in api
  mp.osd_message("Jimaku: searching " .. title, OSD_TIMEOUT)
  local entry = search(title)[1]
  if not entry then
    mp.osd_message("Jimaku: no results for " .. title, OSD_TIMEOUT)
    return
  end

  -- get subtitle file for episode
  mp.osd_message("Jimaku: found " .. entry.name, OSD_TIMEOUT)
  local file = get_files(entry.id, episode)[1]
  if not file then
    mp.osd_message("Jimaku: no subtitle for episode " .. episode, OSD_TIMEOUT)
    return
  end

  -- download and add subtitle
  local sub_path = buildSubtitlePath(filename, file.url)
  download(file.url, sub_path)
  syncSubtitles(sub_path)
  mp.commandv("sub-add", sub_path)
  mp.osd_message("Jimaku: downloaded " .. filename, OSD_TIMEOUT)
end

-- Key binding
mp.add_key_binding("ctrl+j", "jimaku-sub-fetcher", main)
