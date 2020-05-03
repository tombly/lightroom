
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
-- Wrap a string with quotes. If the string is nil then return an empty string.

local function wrap (inputstr)
	if inputstr == nil then
		return ""
	else
		return '"' .. inputstr .. '"'
	end
end

-------------------------------------------------------------------------------
-- Options

local collectionSetName = "From Lightroom" -- Set to the collection set of interest.
local outputFilePath = "/Users/tomb/Desktop/Photos.csv" -- Full path to the output file.

-------------------------------------------------------------------------------
-- This function writes a variety of photo metadata to a file. See the SDK
-- documentation for details about what each value means.

local function go()
	local catalog = LrApplication.activeCatalog()

	LrTasks.startAsyncTask(
		function()
			outputToLog("Script started: " .. catalog:getPath())

			-- Step through each high-level collection
			for i, v in ipairs(catalog:getChildCollectionSets()) do
				if collectionSetName == v:getName() then
					
					local file = io.open(outputFilePath, "w")
					io.output(file)
					io.write("CollectionName,FileName,Title,Caption,FileName,GPS,FileSize,Rating,Width,Height,FileFormat,DateTimeOriginal,DateTimeDigitized,DateTime,LastEditTime,EditCount,IsVideo,DurationInSeconds,ShutterSpeed,Aperture,ExposureBias,Flash,ISOSpeedRating,FocalLength,FocalLength35mm\n")

					-- Step through each child collection
					for i, v in ipairs(v:getChildCollections()) do

						-- Step through each photo
						for i, p in ipairs(v:getPhotos()) do
							local line = ""

							line = line .. wrap(v:getName()) .. ","	
							line = line .. wrap(p:getFormattedMetadata("fileName")) .. ","
							line = line .. wrap(p:getFormattedMetadata("title")) .. ","
							line = line .. wrap(p:getFormattedMetadata("caption")) .. ","
							line = line .. wrap(p:getFormattedMetadata("fileName")) .. ","
							line = line .. wrap(p:getFormattedMetadata("gps")) .. ","
							line = line .. wrap(p:getRawMetadata("fileSize")) .. ","
							line = line .. wrap(p:getRawMetadata("rating")) .. ","
							line = line .. wrap(p:getRawMetadata("width")) .. ","
							line = line .. wrap(p:getRawMetadata("height")) .. ","
							line = line .. wrap(p:getRawMetadata("fileFormat")) .. ","
							line = line .. wrap(p:getRawMetadata("dateTimeOriginalISO8601")) .. ","
							line = line .. wrap(p:getRawMetadata("dateTimeDigitizedISO8601")) .. ","
							line = line .. wrap(p:getRawMetadata("dateTimeISO8601")) .. ","
							line = line .. wrap(p:getRawMetadata("lastEditTime")) .. ","
							line = line .. wrap(p:getRawMetadata("editCount")) .. ","
							line = line .. wrap(tostring(p:getRawMetadata("isVideo"))) .. ","
							line = line .. wrap(p:getRawMetadata("durationInSeconds")) .. ","
							line = line .. wrap(p:getRawMetadata("shutterSpeed")) .. ","
							line = line .. wrap(p:getRawMetadata("aperture")) .. ","
							line = line .. wrap(p:getRawMetadata("exposureBias")) .. ","
							line = line .. wrap(tostring(p:getRawMetadata("flash"))) .. ","
							line = line .. wrap(p:getRawMetadata("isoSpeedRating")) .. ","
							line = line .. wrap(p:getRawMetadata("focalLength")) .. ","
							line = line .. wrap(p:getRawMetadata("focalLength35mm"))

							io.write(line .. "\n")

						end
					end -- for getChildCollections

					io.close(file)

				end -- if target collection
			end -- for collection sets

			outputToLog("Script stopped")

		end -- function
	) -- async task
end

go()
