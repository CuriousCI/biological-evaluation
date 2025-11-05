// R-HSA-198753.3, // ERK/MAPK targets
// R-HSA-199920.3,  // CREB phosphorylation
// R-HSA-170670.5, // Adenylate cyclase inhibitory pathway
// R-HSA-114508.4, // Effects of PIP2 hydrolysis
// R-HSA-354192.4, // Integrin signaling
// R-HSA-2173793.6, // Transcriptional activity of SMAD2/SMAD3:SMAD4 heterotrimer
//
//
//
// R-HSA-162582.13 // What I want to expand!
//
// A the end of the day this is just an experiment
MATCH (reaction:ReactionLikeEvent)-[:hasEvent]-(pathway:Pathway)
WHERE
  pathway.stIdVersion IN [
    'R-HSA-198753.3',
    'R-HSA-199920.3',
    'R-HSA-170670.5',
    'R-HSA-114508.4',
    'R-HSA-354192.4',
    'R-HSA-2173793.6'
  ]
RETURN COUNT(DISTINCT reaction);

MATCH (reaction:ReactionLikeEvent)-[:hasEvent]-(pathway:Pathway)
WHERE
  pathway.stIdVersion = 'R-HSA-162582.13' AND
  NOT EXISTS {
    MATCH (reaction)-[:hasEvent]-(ignoredPathway:Pathway)
    WHERE
      ignoredPathway.stIdVersion IN [
        'R-HSA-198753.3',
        'R-HSA-199920.3',
        'R-HSA-170670.5',
        'R-HSA-114508.4',
        'R-HSA-354192.4',
        'R-HSA-2173793.6'
      ]

  }
RETURN COUNT(DISTINCT reaction);

// This one too, to check if it works
MATCH
  path =
    (reaction:ReactionLikeEvent)-[:hasEvent*3..3]-
    (pathway:Pathway {stIdVersion: 'R-HSA-162582.13'})
WHERE
  NONE(
    node IN nodes(path)
    WHERE
      node IN [
        'R-HSA-198753.3',
        'R-HSA-199920.3',
        'R-HSA-170670.5',
        'R-HSA-114508.4',
        'R-HSA-354192.4',
        'R-HSA-2173793.6'
      ]
  )
RETURN COUNT(path);

// Interesting "species" or components within a signal transduction pathway include ligands (signaling molecules), receptors (like G-protein coupled receptors), second messengers (such as cAMP), kinases and phosphatases (enzymes that add or remove phosphate groups), G proteins (like Ras), and transcription factors. These molecules initiate, relay, and amplify signals, leading to changes in cellular behavior like growth, metabolism, or immune response, depending on the specific pathway involved

// dbId: 202124 NO (Nytric Oxyde) R-ALL-202124.3
