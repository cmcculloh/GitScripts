#********************************************************
# REFRESH LOCAL DEV ENDECA
#********************************************************

#secure copy
#scp [from] [to]




#connect to dev endeca

#tar up /usr/local/endeca/finishline/config/pipeline/*
#move tar to /usr/local/endeca/finishline/config/pipeline_backups/ with date appended

#tar up /usr/local/endeca/finishline/data/state/*
#move tar to /usr/local/endeca/finishline/data/state_backups/ with date appended
#don't need to copy this one down since we don't do anything with it...

#disconnect from endeca

#copy down pipeline tar to D:\Applications\Endeca\Deploy\new\Dev\BackUpDev\

#untar pipeline tar to  D:\Applications\Endeca\Deploy\new\Dev\BackUpDev\pipeline\

#delete contents of D:\Applications\Endeca\Deploy\new\Dev\*

#copy D:\Applications\Endeca\Deploy\new\Dev\BackUpDev\pipeline\* into D:\Applications\Endeca\Deploy\new\Dev\

