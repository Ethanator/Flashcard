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
#define DEBUG NO


/* SEANS CONSTANTS */
#define FLASHCARD_DATA_MODEL_NAME @"FlashcardDataModel"
#define DECK_ENTITY_NAME @"Deck"
#define CARD_ENTITY_NAME @"Card"
#define EXTERNALLY_OPENED_URL_DEFAULTS @"externallyOpenedURL"
#define OPEN_EXTERNAL_DECK_COLLECTION_VIEW_MESSAGE @"Please choose a flashcard deck for your card."
#define OK_BUTTON_TITLE @"OK"
#define CARD_TO_RENDER_SEGUE_IDENTIFIER @"ShowRenderViewController"
#define CROP_RECT_WIDTH (170)
#define CROP_RECT_HEIGHT (150)
#define RECT_IMAGE_NAME @"rect.png"

/* SHUYANGS CONSTANTS */
#define CARD_COLLECTION_VIEW_CELL_IDENTIFIER @"Card"
#define KEY_FOR_IMAGE_COUNTER_IN_NSUSERDEFAULTS @"CounterForImageUniqueID"

// below are titles for buttons for adding a new card
#define ADD_CARD_ACTION_SHEET_TITLE nil
#define ADD_CARD_CANCEL_BUTTON_TITLE @"Cancel"
#define ADD_CARD_DESTRUCTIVE_BUTTON_TITLE nil
#define ADD_CARD_OTHER_BUTTON_TITLES @"Text", @"Web", @"Camera", nil

// below are titles for buttons for prompting for text input
#define PROMPT_FOR_TEXT_TITLE @"Text on flashcard"
#define PROMPT_FOR_TEXT_MESSAGE nil
#define PROMPT_FOR_TEXT_CANCEL_BUTTON_TITLE @"Cancel"
#define PROMPT_FOR_TEXT_OTHER_BUTTON_TITLES @"Done", nil

// below are titles for buttons for prompting for url input
#define PROMPT_FOR_URL_TITLE @"URL of file"
#define PROMPT_FOR_URL_MESSAGE nil
#define PROMPT_FOR_URL_CANCEL_BUTTON_TITLE @"Cancel"
#define PROMPT_FOR_URL_OTHER_BUTTON_TITLES @"Done", nil

// below are for text rendering
#define RENDERED_TEXT_SIZE 26.0f

// below is for animated flipping
#define FLIPPING_ANIMATION_DURATION 0.5

// below are for custom UIImageView
#define CARD_IMAGE_CORNER_RADIUS 8.0

/* ETHANS CONSTANTS */
#define DECK_COLLECTION_VIEW_CELL_IDENTIFIER @"Deck"
#define DECK_TO_CARD_SEGUE_IDENTIFIER @"DeckToCard"
#define ALERT_VIEW_TITLE @"New Deck"
#define ALERT_VIEW_RENAME_FILE @"Rename Deck"
#define ALERT_VIEW_MESSAGE @"Please enter the name of the deck."
#define ALERT_VIEW_CANCEL_BUTTON @"Cancel"
#define ALERT_VIEW_OTHER_BUTTON @"OK",nil
#define LX_LIMITED_MOVEMENT 0

#endif
