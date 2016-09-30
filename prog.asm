.data
	num: .float -31.0

.text
	l.s $f0, num
	cvt.w.s $f1, $f0
	
	mfc1 $t0, $f1