function fail( x)
{
	print name " Failed " x
	exit(0)
}

function abs(x)
{
	return x<0?-x:x
}

function ignore_and_process(line,       a)
{
	if(line ~ /^[[:space:]]*$/) #Ignore blank linkes
		return 1
	else if (line ~ /^[[:space:]]*#>/) #Process directives, then ignore the line
	{
		split(line, a)
		if(a[2] == "t")
			t = a[3]

		return 1
	}
	else if (line ~ /^[[:space:]]*#/) #Ignore comments
		return 1
	else   #The line should not be ignored
		return 0
}

BEGIN{

	#This program compares two files to see if they are the same
	#Whitespace is ignored
	#Numbers must match to within a given threshold.

	#Lines starting with a # are also ignored.
	#If a # is *not* the first non-whitespace, then it is not ignored.
	#Lines starting with #> are directives and are processed further
	#Directives are
	#   #> t xx                 Set t to xx

	if(t == "")
		t = 1e-6

	for(;;)
	{
		#Get the next non blank line from the two files
		do
		 status1 = (getline s1 < f1)
		while(status1 && ignore_and_process(s1))

		do
		 status2 = (getline s2 < f2)
		while(status2 && ignore_and_process(s2))
		
		#Check to see if the files have both ended
		if(status1 != status2)
			fail("file length mismatch")
		else if(status1 == 0 && status2 == 0)
		{
			print name " Passed"
			exit(0)
		}

		if(s1 == "Crash!!!" || s2 == "Crash!!!")
			fail("Crash!!!")

		if(s1 == "Compile error!" || s2 == "Compile error!")
			fail("Compile error!")

		#If there are valid lines left, then split them
		#into fields
		n1 = split(s1, a1)
		n2 = split(s2, a2)

		#Check for matching linesize
		if(n1 != n2)
			fail("line length mismatch >>>"s1"<<< >>>"s2"<<<<");
		
		#Compare fields
		for(i=1; i <= n1; i++)
		{
			#If both fields are floats, then use a threshold based
			#match otherwise use an exact match
			if(a1[i] ~ /^-?(([0-9]+\.[0-9]*)|(\.?[0-9]+))([eE][-+][0-9]+)?$/ &&
			   a2[i] ~ /^-?(([0-9]+\.[0-9]*)|(\.?[0-9]+))([eE][-+][0-9]+)?$/)
			{
				if(abs(a1[i] - a2[i]) > t)
					fail("number  " a1[i] " " a2[i])
			}
			else if(a1[i] != a2[i])
				fail("string >>>"a1[i]"<<< >>>"a2[i]"<<<<")
		}
	}


}
