"
I am a test case specialized in checking that the announcements linked to protocol management are right.
"
Class {
	#name : #ProtocolAnnouncementsTest,
	#superclass : #ProtocolTest,
	#instVars : [
		'numberOfAnnouncements'
	],
	#category : #'Kernel-Tests-Protocols'
}

{ #category : #running }
ProtocolAnnouncementsTest >> setUp [

	super setUp.
	numberOfAnnouncements := 0
]

{ #category : #running }
ProtocolAnnouncementsTest >> tearDown [

	SystemAnnouncer uniqueInstance unsubscribe: self.
	super tearDown
]

{ #category : #'tests - adding' }
ProtocolAnnouncementsTest >> testAddProtocolAnnouncement [

	self when: ProtocolAdded do: [ :ann |
		self assert: ann protocol name equals: #king.
		self assert: ann classReorganized name equals: self classNameForTests ].

	self when: ClassReorganized do: [ :ann | self assert: ann classReorganized name equals: self classNameForTests ].

	organization addProtocol: #king.
	self assert: numberOfAnnouncements equals: 2
]

{ #category : #'tests - adding' }
ProtocolAnnouncementsTest >> testAddProtocolAnnouncement2 [

	self when: ProtocolAdded do: [ :ann |
		self assert: ann protocol name equals: #king.
		self assert: ann classReorganized name equals: self classNameForTests ].

	self when: ClassReorganized do: [ :ann | self assert: ann classReorganized name equals: self classNameForTests ].

	organization addProtocol: (Protocol named: #king).
	self assert: numberOfAnnouncements equals: 2
]

{ #category : #tests }
ProtocolAnnouncementsTest >> testClassifyUnderAnnounceNewProtocol [

	self when: ProtocolAdded do: [ :ann |
		self assert: ann protocol name equals: #titan.
		self assert: ann classReorganized name equals: self classNameForTests ].

	self when: ClassReorganized do: [ :ann | self assert: ann classReorganized name equals: self classNameForTests ].

	organization classify: #king under: #titan.
	self assert: numberOfAnnouncements equals: 2
]

{ #category : #'tests - removing' }
ProtocolAnnouncementsTest >> testRemoveProtocolAnnouncement [

	organization addProtocol: #titan.

	self when: ProtocolRemoved do: [ :ann |
		self assert: ann protocol name equals: #titan.
		self assert: ann classReorganized name equals: self classNameForTests ].

	self when: ClassReorganized do: [ :ann | self assert: ann classReorganized name equals: self classNameForTests ].

	class removeProtocolIfEmpty: #titan.

	self assert: numberOfAnnouncements equals: 2
]

{ #category : #'tests - removing' }
ProtocolAnnouncementsTest >> testRemoveProtocolAnnouncement2 [

	organization addProtocol: #titan.

	self when: ProtocolRemoved do: [ :ann |
		self assert: ann protocol name equals: #titan.
		self assert: ann classReorganized name equals: self classNameForTests ].

	self when: ClassReorganized do: [ :ann | self assert: ann classReorganized name equals: self classNameForTests ].

	class removeProtocolIfEmpty: (class protocolNamed: #titan).

	self assert: numberOfAnnouncements equals: 2
]

{ #category : #'tests - removing' }
ProtocolAnnouncementsTest >> testRemoveProtocolAnnouncement3 [

	organization addProtocol: #titan.
	class compiler
		protocol: #titan;
		install: 'king ^ 1'.

	self when: ProtocolRemoved do: [ :ann |
		self assert: ann protocol name equals: #titan.
		self assert: ann classReorganized name equals: self classNameForTests ].

	self when: ClassReorganized do: [ :ann | self assert: ann classReorganized name equals: self classNameForTests ].

	class removeProtocol: #titan.

	self assert: numberOfAnnouncements equals: 2
]

{ #category : #'tests - removing' }
ProtocolAnnouncementsTest >> testRemoveProtocolAnnouncement4 [

	organization addProtocol: #titan.

	self when: ProtocolRemoved do: [ :ann |
		self assert: ann protocol name equals: #titan.
		self assert: ann classReorganized name equals: self classNameForTests ].

	self when: ClassReorganized do: [ :ann | self assert: ann classReorganized name equals: self classNameForTests ].

	class removeProtocol: #titan.

	self assert: numberOfAnnouncements equals: 2
]

{ #category : #'tests - removing' }
ProtocolAnnouncementsTest >> testRemoveProtocolIfEmptyWithNonEmptyProtocolDoesNotAnnounceAnything [

	organization addProtocol: #titan.
	class compiler
		protocol: #titan;
		install: 'king ^ 1'.

	self when: ProtocolRemoved do: [ :ann | self fail ].

	self when: ClassReorganized do: [ :ann | self fail ].

	class removeProtocolIfEmpty: #titan.

	self assert: numberOfAnnouncements equals: 0
]

{ #category : #'tests - removing' }
ProtocolAnnouncementsTest >> testRemoveProtocolIfEmptyWithNonExistingProtocolDoesNotAnnounceAnything [

	self when: ProtocolRemoved do: [ :ann | self fail ].

	self when: ClassReorganized do: [ :ann | self fail ].

	class removeProtocolIfEmpty: #nonexisting.

	self assert: numberOfAnnouncements equals: 0
]

{ #category : #'tests - removing' }
ProtocolAnnouncementsTest >> testRemoveProtocolIfEmptyWithNonExistingProtocolDoesNotAnnounceAnything2 [

	self when: ProtocolRemoved do: [ :ann | self fail ].

	self when: ClassReorganized do: [ :ann | self fail ].

	class removeProtocolIfEmpty: (Protocol named: #nonexisting).

	self assert: numberOfAnnouncements equals: 0
]

{ #category : #tests }
ProtocolAnnouncementsTest >> testRenameProtocolAsAnnounceClassReorganizedOnce [
	"This is a regerssion test because at some point the class reorganized announcement got duplicated."

	organization classify: #king under: #demon.

	self when: ClassReorganized do: [ :ann | self assert: ann classReorganized name equals: self classNameForTests ].

	organization renameProtocol: #demon as: #titan.

	self assert: numberOfAnnouncements equals: 1
]

{ #category : #tests }
ProtocolAnnouncementsTest >> testRenameProtocolAsAnnounceNewProtocol [

	self skip. "This hihglight the problem of https://github.com/pharo-project/pharo/pull/13494
	But we still need to work on this to fix this test."

	organization classify: #king under: #demon.

	self when: ProtocolAdded do: [ :ann |
		self assert: ann protocol name equals: #titan.
		self assert: ann classReorganized name equals: self classNameForTests ].

	self when: ClassReorganized do: [ :ann | self assert: ann classReorganized name equals: self classNameForTests ].

	organization renameProtocol: #demon as: #titan.

	self assert: numberOfAnnouncements equals: 2
]

{ #category : #helpers }
ProtocolAnnouncementsTest >> when: anAnnouncement do: aBlock [

	SystemAnnouncer uniqueInstance
		when: anAnnouncement
		do: [ :ann |
			numberOfAnnouncements := numberOfAnnouncements + 1.
			aBlock cull: ann ]
		for: self
]
