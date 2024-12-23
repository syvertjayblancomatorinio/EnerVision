const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const communitySchema = new Schema({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  postId: { type: Schema.Types.ObjectId, ref: 'Post', required: true },
  deletedAt: Date,
}, { timestamps: true });

const Community = mongoose.model('Community', communitySchema);

module.exports = Community;
