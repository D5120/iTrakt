script iTunesBridge
  

    on show()
        tell application "System Events"
            if (name of every process) does not contain "iTunes" then
                return
            end if
        end tell
        
        using terms from application "iTunes"
            tell application "iTunes"
                return show of current track
            end tell
        end using terms from
    end
    
    on episodeName()
        tell application "System Events"
            if (name of every process) does not contain "iTunes" then
                return
            end if
        end tell
        
        using terms from application "iTunes"
            tell application "iTunes"
                return name of current track
            end tell
        end using terms from
    end
    
    on tvdbID()
        tell application "System Events"
            if (name of every process) does not contain "iTunes" then
                return
            end if
        end tell
        
        using terms from application "iTunes"
            tell application "iTunes"
                return episode ID of current track
            end tell
        end using terms from
    end
    
    on databaseID()
        tell application "System Events"
            if (name of every process) does not contain "iTunes" then
                return
            end if
        end tell
        
        using terms from application "iTunes"
            tell application "iTunes"
                return database ID of current track
            end tell
        end using terms from
    end
    
    on seasonNumberString()
        tell application "System Events"
            if (name of every process) does not contain "iTunes" then
                return
            end if
        end tell
        
        using terms from application "iTunes"
            tell application "iTunes"
                return season number of current track
            end tell
        end using terms from
    end
    
    on episodeNumberString()
        tell application "System Events"
            if (name of every process) does not contain "iTunes" then
                return
            end if
        end tell
        
        using terms from application "iTunes"
            tell application "iTunes"
                return episode number of current track
            end tell
        end using terms from
    end
    
    on playCountString()
        tell application "System Events"
            if (name of every process) does not contain "iTunes" then
                return
            end if
        end tell
        
        using terms from application "iTunes"
            tell application "iTunes"
                return played count of current track
            end tell
        end using terms from
    end
    
    on showYearString()
        tell application "System Events"
            if (name of every process) does not contain "iTunes" then
                return
            end if
        end tell
        
        using terms from application "iTunes"
            tell application "iTunes"
                return year of current track
            end tell
        end using terms from
    end
    
    on durationString()
        tell application "System Events"
            if (name of every process) does not contain "iTunes" then
                return
            end if
        end tell
        
        using terms from application "iTunes"
            tell application "iTunes"
                return duration of current track
            end tell
        end using terms from
    end
    
    on videoKind()
        tell application "System Events"
            if (name of every process) does not contain "iTunes" then
                return
            end if
        end tell
        
        using terms from application "iTunes"
            tell application "iTunes"
                return video kind of current track as string
            end tell
        end using terms from
    end
    
    on playCountOfTrack_(trackNumber)
        
        set tracknum to (trackNumber as integer)
        
        tell application "System Events"
            if (name of every process) does not contain "iTunes" then
                return
            end if
        end tell
        
        using terms from application "iTunes"
            tell application "iTunes"
                set lib_ref to first library playlist
                set track_id to (database ID of some track of lib_ref)
                tell lib_ref
                    set track_ref to (last track whose database ID is tracknum)
                end tell
                return played count of track_ref
            end tell
        end using terms from
    end
    


end script