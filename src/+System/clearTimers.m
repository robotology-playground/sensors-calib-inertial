function clearTimers()
%Clears all the running timers

timersArray = timerfind;
for idx = 1:length(timersArray)
    delete(timersArray(idx));
end

end
