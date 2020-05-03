
-- Access the Lightroom SDK namespaces.
local LrDialogs = import "LrDialogs"
local LrLogger = import "LrLogger"
local LrApplication = import "LrApplication"
local LrTasks = import "LrTasks"
local LrErrors = import "LrErrors"

-- Create the logger and enable the print function.
local myLogger = LrLogger("nosleepLogger")
myLogger:enable("logfile") -- print or logfile

-------------------------------------------------------------------------------
-- Write trace information to the logger.

local function outputToLog(message)
	myLogger:trace(message)
end

-------------------------------------------------------------------------------
-- Split a string into tokens.

local function mysplit (inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end

-------------------------------------------------------------------------------
-- Options

local dryRun = true -- Set to false to actually update the photo titles.
local collectionSetName = "From Lightroom" -- Set to the collection set of interest.

-------------------------------------------------------------------------------
-- This function sets the titles of the photos within each collection to the
-- name of the collection. I.e. all collections are expected to be named with
-- a year/month prefix:
--
--   2017-03 Family Picnic
--   2018-10 Halloween
--   2018-11 Thanksgiving
--
-- The function performs some validation of the format of the collection names
-- and then sets the title of each photo to the collection name with the
-- year/month prefix changed to a suffix:
--
--   Family Picnic (2017-03)
--   Halloween (2018-10)
--   Thanksgiving (2018-11)

local function go()
	local catalog = LrApplication.activeCatalog()

	LrTasks.startAsyncTask(
		function()
			outputToLog("Script started: " .. catalog:getPath())

			-- Step through each high-level collection
			for i, v in ipairs(catalog:getChildCollectionSets()) do
				if collectionSetName == v:getName() then
					outputToLog("Found '" .. collectionSetName .. "'")

					for i, v in ipairs(v:getChildCollections()) do

						-- Extract contents of the folder name
						local tokens = mysplit(v:getName(), ' ')
						local datePrefix = tokens[1]

						-- Make sure the date prefix has the right length
						if #datePrefix ~= 7 then
							LrErrors.throwUserError("Error: Bad date prefix: " .. datePrefix)
						end							

						-- Make sure the date prefix contains a dash
						if string.match(datePrefix, "-") == false then
							LrErrors.throwUserError("Error: Bad date prefix: " .. datePrefix)
						end

						-- Make sure the year and month look legit
						local date_tokens = mysplit(datePrefix, "-")
						local year = tonumber(date_tokens[1])
						local month = tonumber(date_tokens[2])
						if datePrefix ~= "0000-00" then
							if year < 1950 or year > 2020 then
								LrErrors.throwUserError("Error: Bad year: " .. year)
							end
							if month < 1 or month > 12 then
								LrErrors.throwUserError("Error: Bad month: " .. month)
							end
						end

						-- Generate the title and log it.
						local title = v:getName():sub(9,#v:getName())
						outputToLog("Updating " .. tostring(#v:getPhotos()) .. " photo titles to '" .. title .. "'")

						-- Update the title for all photos in this folder.
						catalog:withWriteAccessDo(
							"Title Update",
							function()
								for i, p in ipairs(v:getPhotos()) do
									if dryRun == false then
										p:setRawMetadata('title', title)
									end
								end
							end
						) -- withWriteAccessDo

					end -- for getChildCollections
				end -- if target collection
			end -- for collection sets

			outputToLog("Script stopped")
		
		end -- function
	) -- async task
end

go()
