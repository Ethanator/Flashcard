//
//  Constants.h
//  Flashcard
//
//  Created by Sean Fitzgerald on 10/4/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#ifndef Flashcard_Constants_h
#define Flashcard_Constants_h

// USE THIS AS NEEDED - comment below what it does in case somebody else is using it
#define DEBUG YES


/* SEANS CONSTANTS */
#define FLASHCARD_DATA_MODEL_NAME @"FlashcardDataModel"
#define DECK_ENTITY_NAME @"Deck"
#define CARD_ENTITY_NAME @"Card"
#define EXTERNALLY_OPENED_URL_DEFAULTS @"externallyOpenedURL"
#define OPEN_EXTERNAL_DECK_COLLECTION_VIEW_MESSAGE @"Please choose a flashcard deck for your card:"
#define OK_BUTTON_TITLE @"OK"
#define CARD_TO_RENDER_SEGUE_IDENTIFIER @"ShowRenderViewController"

/* SHUYANGS CONSTANTS */
#define CARD_COLLECTION_VIEW_CELL_IDENTIFIER @"Card"

// below are titles for buttons for adding a new card
#define ADD_CARD_ACTION_SHEET_TITLE nil
#define ADD_CARD_CANCEL_BUTTON_TITLE @"Cancel"
#define ADD_CARD_DESTRUCTIVE_BUTTON_TITLE nil
#define ADD_CARD_OTHER_BUTTON_TITLES @"Text", @"Web", @"Camera", nil

// below are titles for buttons for prompting for text input
#define PROMPT_FOR_TEXT_TITLE @"Text Input"
#define PROMPT_FOR_TEXT_MESSAGE @"Please type in the text on the flashcard:"
#define PROMPT_FOR_TEXT_CANCEL_BUTTON_TITLE @"Cancel"
#define PROMPT_FOR_TEXT_OTHER_BUTTON_TITLES nil

/* ETHANS CONSTANTS */
#define DECK_COLLECTION_VIEW_CELL_IDENTIFIER @"Deck"
#define DECK_TO_CARD_SEGUE_IDENTIFIER @"DeckToCard"

#endif
